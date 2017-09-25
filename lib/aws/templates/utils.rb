require 'aws/templates/exceptions'

module Aws
  module Templates
    ##
    # Variable utility functions used through the code
    module Utils
      RECURSIVE_METHODS = %i[keys [] include?].freeze

      ##
      # If the object is "recursive"
      #
      # Checks if object satisfies "recursive" concept. See RECURSIVE_METHODS for the list
      # of methods
      def self.recursive?(obj)
        RECURSIVE_METHODS.all? { |m| obj.respond_to?(m) }
      end

      ##
      # If the object is "scalar"
      #
      # Checks if object satisfies "scalar" concept.
      def self.scalar?(obj)
        !obj.respond_to?(:[])
      end

      ##
      # If object is hashable
      #
      # Checks if object can be transformed into Hash
      def self.hashable?(obj)
        obj.respond_to?(:to_hash)
      end

      PARAMETRIZED_METHODS = [:parameter_names].freeze

      ##
      # If the object is "parametrized"
      #
      # Checks if object satisfies "parametrized" concept. See PARAMETRIZED_METHODS for the list
      # of methods
      def self.parametrized?(obj)
        PARAMETRIZED_METHODS.all? { |m| obj.respond_to?(m) }
      end

      ##
      # If object is a list
      #
      # Checks if object can be transformed into Array
      def self.list?(obj)
        obj.respond_to?(:to_ary)
      end

      ##
      # Duplicate hash recursively
      #
      # Duplicate the hash and all nested hashes recursively
      def self.deep_dup(original)
        return original unless Utils.hashable?(original)

        duplicate = original.dup.to_hash
        duplicate.each_pair { |k, v| duplicate[k] = deep_dup(v) }

        duplicate
      end

      ##
      # Merges two nested hashes
      #
      # The core element of the whole framework. The principle is simple:
      # both arguments are transformed to hashes if they support :to_hash
      # method, the resulting hashes are merged with the standard method
      # with creating a new hash. Second element takes preference if the
      # function reached bottom level of recursion with only scalars left.
      #
      # Raises ArgumentError if a and b have incompatible types hence
      # they can't be merged
      #
      # ==== Example
      #
      #    Options.merge('a', 'b') # => 'b'
      #    Options.merge({'1'=>'2'}, {'3'=>'4'}) # => {'1'=>'2', '3'=>'4'}
      #    Options.merge(
      #      { '1' => { '2' => '3' } },
      #      { '1' => { '4' => '5' } }
      #    ) # => { '1' => { '2' => '3', '4'=>'5' } }
      ##
      # Recursively merge two "recursive" objects
      # PS: Yes I know that there is "merge" method for *hashes*.
      def self.merge(a, b)
        return hashify(b) unless Utils.recursive?(a) && Utils.recursive?(b)
        _merge_back(_merge_forward(a, b), b)
      end

      def self._merge_forward(a, b)
        a.keys.each_with_object({}) do |k, hsh|
          hsh[k] = b[k].nil? ? hashify(a[k]) : merge(a[k], b[k])
        end
      end

      def self._merge_back(result, b)
        b.keys.reject { |k| result.include?(k) }.each_with_object(result) { |k, res| res[k] = b[k] }
      end

      def self.hashify(v)
        return v unless Utils.recursive?(v)
        v.keys.each_with_object({}) { |k, hsh| hsh[k] = hashify(v[k]) }
      end

      ##
      # Deletion marker
      #
      # Since Options use lazy merging (effectively keeping all hashes passed during
      # initialization immutable) and iterates through all of them during value look-up, we need
      # a way of marking some branch as deleted when deletion operation is invoked on an Options
      # object. So, the algorithm marks branch with the object to stop iteration during look-up.
      DELETED_MARKER = Object.new

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
      def self.lookup(value, path)
        # we stop lookup and return nil if nil is encountered
        return if value.nil?
        # value was deleted in this layer
        raise OptionValueDeleted.new(path) if value == DELETED_MARKER
        # we reached our target! returning it
        return value if path.nil? || path.empty?
        # we still have some part of path to traverse but scalar was found
        raise OptionScalarOnTheWay.new(value, path) if Utils.scalar?(value)

        _lookup_recursively(value, path.dup)
      end

      def self._lookup_recursively(value, path)
        current_key = path.shift

        # is there a value defined for the key in the current recursive structure?
        if value.include?(current_key)
          # yes - look-up the rest of the path
          return_value = lookup(value[current_key], path)
          # if value was still not found - resorting to wildcard path
          return_value.nil? ? lookup(value[:*], path) : return_value
        elsif value.include?(:*)
          # if there is no key but the recursive has a default value defined - dive into the
          # wildcard branch
          lookup(value[:*], path)
        end
      end

      ##
      # Sets a value in hierarchy
      #
      # Sets a path in a nested recursive hash structure to the specified value
      #
      # * +container+ - container with the specified path
      # * +value+ - the value to set the path to
      # * +path+ - path containing the target value
      def self.set_recursively(container, value, path)
        last_key = path.pop

        last_branch = path.inject(container) do |obj, current_key|
          raise OptionScalarOnTheWay.new(obj, path) unless Utils.recursive?(obj)
          if obj.include?(current_key)
            obj[current_key]
          else
            obj[current_key] = {}
          end
        end

        last_branch[last_key] = value
      end

      ##
      # Select object recursively
      #
      # Selects objects recursively from the specified container with specified block predicate.
      #
      # * +container+ - container to recursively select items from
      # * +blk+ - the predicate
      def self.select_recursively(container, &blk)
        container.keys.each_with_object([]) do |k, collection|
          value = container[k]
          if blk.call(value)
            collection << value
          elsif Utils.recursive?(value)
            collection.concat(select_recursively(value, &blk))
          end
        end
      end
    end
  end
end
