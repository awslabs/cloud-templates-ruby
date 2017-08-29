require 'set'
require 'aws/templates/exceptions'
require 'aws/templates/utils'
require 'aws/templates/utils/memoized'

module Aws
  module Templates
    module Utils
      # rubocop:disable Metrics/ClassLength

      ##
      # Options hash-like class
      #
      # Implements the core mechanism of hash lookup, merge, and transformation.
      #
      # It supports nested hash lookup with index function and wildcard
      # hash definitions on any level of nested hierarchy so you can define
      # fallback values right in the input hash. The algorithm will try to
      # select the best combination if it doesn't see the exact match
      # during lookup.
      class Options
        include Memoized

        ##
        # Get a parameter from resulting hash or any nested part of it
        #
        # The method can access resulting hash as a tree performing
        # traverse as needed. Also, it handles nil-pointer situations
        # correctly so you will get no exception but just 'nil' even when
        # the whole branch you're trying to access don't exist or contains
        # non-hash value somewhere in the middle. Also, the method
        # recognizes asterisk (*) hash records which is an analog of
        # match-all or default values for some sub-branch.
        #
        # * +path+ - an array representing path of the value in the nested
        #            hash
        #
        # ==== Example
        #
        #    opts = Options.new(
        #      'a' => {
        #        'b' => 'c',
        #        '*' => { '*' => 2 }
        #      },
        #      'd' => 1
        #    )
        #    opts.to_hash # => { 'a' => { 'b' => 'c', '*' => { '*' => 2 } }, 'd' => 1 }
        #    opts['a'] # => Options.new('b' => 'c', '*' => { '*' => 2 })
        #    opts['a', 'b'] # => 'c'
        #    opts['d', 'e'] # => nil
        #    # multi-level wildcard match
        #    opts['a', 'z', 'r'] # => 2
        def [](*path)
          @structures.reverse_each.inject(nil) do |memo, container|
            ret = begin
              Utils.lookup(container, path.dup)
            rescue OptionValueDeleted, OptionScalarOnTheWay
              # we discovered that this layer either have value deleted or parent was overriden
              # by a scalar. Either way we just return what we have in the memo
              break memo
            end

            # if current container doesn't have this value - let's go to the next iteration
            next memo if ret.nil?

            # if found value is a scalar then either we return it as is or return memo
            # if memo is not nil it means that we've found hierarchical objects before
            break(memo.nil? ? ret : memo) unless Utils.recursive?(ret)

            # value is not a scalar. it means we need to keep merging them
            memo.nil? ? Options.new(ret) : memo.unshift_layer!(ret)
          end
        end

        def dependency?
          !dependencies.empty?
        end

        def dependencies
          memoize(:dependencies) do
            select_recursively(&:dependency?)
              .inject(Set.new) { |acc, elem| acc.merge(elem.dependencies) }
          end
        end

        def select_recursively(&blk)
          Utils.select_recursively(self, &blk)
        end

        ##
        # Set the parameter with the path to the value
        #
        # The method can access resulting hash as a tree performing
        # traverse as needed. When stubled uponAlso, it handles non-existent
        # keys correctly creating sub-branches as necessary. If a non-hash
        # and non-nil value discovered in the middle of the path, an exception
        # will be thrown. The method doesn't give any special meaning
        # to wildcards keys so you can set wildcard parameters also.
        #
        # * +path+ - an array representing path of the value in the nested
        #            hash
        # * +value+ - value to set the parameter to
        #
        # ==== Example
        #
        #    opts = Options.new({})
        #    opts.to_hash # => {}
        #    opts['a', 'b'] = 'c'
        #    opts['a', '*', '*'] = 2
        #    opts['d'] = 1
        #    opts.to_hash # => { 'a' => { 'b' => 'c', '*' => { '*' => 2 } }, 'd' => 1 }
        def []=(*path_and_value)
          value = path_and_value.pop
          path = path_and_value
          dirty!.cow! # mooo
          Utils.set_recursively(@structures.last, value, path)
        end

        ##
        # Delete a branch
        #
        # Delete a branch in the options. Rather than deleting it from hash, the path is assigned
        # with special marker that it was deleted. It helps avoid hash recalculation leading to
        # memory thrashing simultaneously maintaining semantics close to Hash#delete
        def delete(*path)
          self[*path] = DELETED_MARKER
        end

        ##
        # Transforms to hash object
        #
        # Produces a hash out of Options object merging COW layers iteratively and calculating them
        # recursively.
        def to_hash
          memoize(:to_hash) do
            _process_hashed(@structures.inject({}) { |acc, elem| Utils.merge(acc, elem) })
          end
        end

        ##
        # Create filter
        #
        # Gets hash representstion of the Options instance and transforms it to filter
        def to_filter
          to_hash.to_filter
        end

        ##
        # Top-level keys
        #
        # Produces a list of top-level keys from all layers. Deleted branches are not included.
        def keys
          memoize(:keys) do
            @structures
              .each_with_object(Set.new) do |container, keyset|
                container.keys.each do |k|
                  container[k] == DELETED_MARKER ? keyset.delete(k) : keyset.add(k)
                end
              end
              .to_a
          end
        end

        ##
        # If top-level key exists
        #
        # Checks if top-level key exists. Deleted branches are excluded.
        def include?(k)
          found = @structures.reverse_each.find { |container| container.include?(k) }
          !found.nil? && (found[k] != DELETED_MARKER)
        end

        ##
        # Merge Options with object
        #
        # Create new Options object which is a merge of the target Options instance with an object.
        # The object must be "recusrsive" meaning it should satisfy minimum contract for
        # "recursive". See Utils::recursive? for details
        def merge(other)
          self.class.new(*@structures, other)
        end

        ##
        # Merge Options with object in-place
        #
        # Put the passed object as the top layer of the current instance.
        # The object must be "recursive" meaning it should satisfy minimum contract for
        # "recursive". See Utils::recursive? for details
        def merge!(other)
          raise OptionShouldBeRecursive.new(other) unless Utils.recursive?(other)
          @structures << other
          dirty!
        end

        ##
        # Filter options
        #
        # Filter options with provided Proc. The proc should accept one parameter satisfying
        # "recursive" contract. See Utils.recursive
        def filter
          Options.new(yield self)
        end

        ##
        # Initialize Options with list of recursive structures (See Options#recursive?)
        def initialize(*structures)
          @structures = structures.map do |container|
            if Utils.recursive?(container)
              container
            elsif Utils.hashable?(container)
              container.to_hash
            else
              raise OptionShouldBeRecursive.new(container)
            end
          end
        end

        ##
        # Duplicate the options
        #
        # Duplicates the object itself and puts another layer of hash map. All original hash maps
        # are not touched if the duplicate is modified.
        def dup
          Options.new(*@structures)
        end

        ##
        # Squash all layers into one
        #
        # Options is designed with very specific goal to be memory-friendly and re-use merged
        # objects as immutable layers. However, after some particular threshold of layer's stack
        # size, performance of index operations can suffer significantly. To mitigate this user can
        # use the method to squash all layers into one aggregated hash.
        #
        # The method performs in-place stack modification
        def compact!
          @structures = [to_hash]
          self
        end

        ##
        # Put the layer to the bottom of the stack
        #
        # However it doesn't resemble exact semantics, the method is similar to reverse_merge!
        # from ActiveSupport. It puts the "recursive" object passed to the bottom of the layer
        # stack of the Options instance effectively making it the least prioritized layer.
        def unshift_layer!(layer)
          raise OptionShouldBeRecursive.new(layer) unless Utils.recursive?(layer)
          @structures.unshift(layer)
          dirty!
        end

        def cow!
          unless @is_cowed
            @structures << {}
            @is_cowed = true
          end

          self
        end

        private

        # :nodoc: process hashable recursively removing all keys marked as deleted
        def _process_hashed(hashed)
          hashed.each_pair do |key, value|
            if value == DELETED_MARKER
              hashed.delete(key)
            elsif Utils.hashable?(value)
              _process_hashed(value.to_hash).freeze
            end
          end

          hashed
        end
      end
    end
  end
end
