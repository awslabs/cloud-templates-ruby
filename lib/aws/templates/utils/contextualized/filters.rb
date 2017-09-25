require 'aws/templates/exceptions'
require 'aws/templates/utils'
require 'aws/templates/utils/options'
require 'aws/templates/utils/inheritable'

module Aws
  module Templates
    module Utils
      ##
      # Filtered mixin.
      #
      # It implements class instance-based definitions of option filters.
      # Filters are options hash alterations and transformations
      # which are defined per-class basis and applied according to class
      # hierarchy when invoked. The target mixing entity should be either
      # Module or Class. In the former case it's possible to model set of
      # object which have common traits organized as an arbitrary graph
      # with many-to-many relationship.
      #
      # Important difference from defaults is that the transformations
      # are performed on a copy of options returned by a separate "filtered"
      # accessor and not in place.
      module Contextualized
        include Inheritable

        ##
        # Filter functor class
        #
        # A filter is a Proc accepting input hash and providing output
        # hash which is expected to be a permutation of the input.
        # The proc is executed in instance context so instance methods can
        # be used for calculation.
        #
        # The class implements functor pattern through to_proc method and
        # closure. Essentially, all filters can be used everywhere where
        # a block is expected.
        #
        # It provides protected method filter which should be overriden in
        # all concrete filter classes.
        class Filter
          ##
          # Proc proxy
          #
          # Just passes opts to the proc the filter was initialized with. It is used internaly.
          class Proxy < Filter
            attr_reader :proc

            def initialize(prc, &blk)
              @proc = prc || blk
            end

            def filter(opts, memo, instance)
              instance.instance_exec(opts, memo, &proc)
            end
          end

          ##
          # No-op filter
          #
          # No-op filter or identity filter doesn't perform any operations on passed options. The
          # role of this filter is to play the role of identity function in par with lambda
          # calculus.
          #
          # === Examples
          #
          #    class Piece
          #      include Aws::Templates::Utils::Contextualized
          #
          #      contextualize filter(:identity)
          #    end
          #
          #    i = Piece.new
          #    opts = Options.new(a: { q: 1 }, b: 2, c: { d: { r: 5 }, e: 1 })
          #    opts.filter(i.filter) # => {}
          class Identity < Filter
            def self.new
              @singleton ||= super()
            end

            def filter(_, memo, _)
              memo
            end

            def &(other)
              other.to_filter
            end
          end

          ##
          # Statically scoped filter
          #
          # Scoped filter wraps whatever Proc obejct passed to it into specified scope for
          # execution. So whatever the scope the filter is called in, it will always be evaluated
          # in the same scope specified at creation.
          #
          # The filter is used by the internal mechanics of the framework.
          class Scoped < Filter
            attr_reader :scoped_filter
            attr_reader :scope

            def initialize(fltr, scp)
              @scoped_filter = _check_filter(fltr)
              @scope = scp
            end

            def filter(options, memo, _)
              scope.instance_exec(options, memo, &scoped_filter)
            end

            private

            def _check_filter(fltr)
              raise "#{fltr} is not a filter" unless fltr.respond_to?(:to_proc)
              fltr
            end
          end

          ##
          # Add all options into the context
          #
          # The filter performs deep copy of entire options hash with consecutive merge into the
          # resulting context
          #
          # === Example
          #
          #    class Piece
          #      contextualize filter(:copy)
          #    end
          #
          #    i = Piece.new()
          #    opts = Options.new(a: { q: 1 }, b: 2, c: { d: { r: 5 }, e: 1 })
          #    opts.filter(i.filter) # => { a: { q: 1 }, b: 2, c: { d: { r: 5 }, e: 1 } }
          class Copy < Filter
            PRE_FILTER = %i[label root parent].freeze

            def filter(opts, memo, _)
              result = Utils.deep_dup(opts.to_hash)
              PRE_FILTER.each { |k| result.delete(k) }
              Utils.merge(memo, result)
            end
          end

          ##
          # Base class for recursive operations
          #
          # Internally used by Add and Remove filters.
          class RecursiveSchemaFilter < Filter
            attr_reader :scheme

            def initialize(*args)
              schm = if args.last.respond_to?(:to_hash)
                args.each_with_object(args.pop) do |field, hsh|
                  hsh[field] = nil
                  hsh
                end
              else
                args
              end

              @scheme = _check_scheme(schm)
            end

            private

            def _check_scheme(schm)
              if schm.respond_to?(:to_hash)
                schm.to_hash.each_pair { |_, sub| _check_scheme(sub) unless sub.nil? }
              elsif !schm.respond_to?(:to_a)
                raise "#{schm.inspect} is not appropriate branch in the scheme"
              end

              schm
            end
          end

          ##
          # Add specified keys into the hash
          #
          # Selective version of Copy filter. It adds key-value pairs or whole subtrees from
          # options into the memo hash. It does this according to specified schema represented
          # by combination of nested hashes and arrays. User can specify addition of values
          # at arbitrary depth in options hash hierarchy with arbitrar granularity.
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Contextualized
          #
          #      contextualize filter(:add, :a, :b, c: [:d])
          #    end
          #
          #    i = Piece.new()
          #    opts = Options.new(a: { q: 1 }, b: 2, c: { d: { r: 5 }, e: 1 })
          #    opts.filter(i.filter) # => { a: { q: 1 }, b: 2, c: { d: { r: 5 } } }
          class Add < RecursiveSchemaFilter
            def filter(options, memo, _)
              _recurse_add(options, memo, scheme)
            end

            private

            def _recurse_add(opts, memo, schm)
              return unless Utils.recursive?(opts)

              if Utils.hashable?(schm)
                _scheme_add(opts, memo, schm.to_hash)
              elsif Utils.list?(schm)
                _list_add(opts, memo, schm.to_ary)
              end

              memo
            end

            def _list_add(opts, memo, list)
              list.each { |field| memo[field] = Utils.merge(memo[field], opts[field]) }
            end

            def _scheme_add(opts, memo, schm)
              schm.each_pair do |field, sub_scheme|
                next unless opts.include?(field)
                memo[field] = if sub_scheme.nil?
                  Utils.merge(memo[field], opts[field])
                else
                  _recurse_add(opts[field], memo[field] || {}, sub_scheme)
                end
              end
            end
          end

          ##
          # Remove specified keys from hash
          #
          # The filter performs removal of values from options hash
          # according to specified schema represented by combination of
          # nested hashes and arrays. User can specify removal of values
          # at arbitrary depth in options hash hierarchy with arbitrary
          # granularity.
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Contextualized
          #
          #      contextualize filter(:copy) & filter(:remove, :a, :b, c: [:d])
          #    end
          #
          #    i = Piece.new()
          #    opts = Options.new(a: { q: 1 }, b: 2, c: { d: { r: 5 }, e: 1 })
          #    opts.filter(i.filter) # => { c: { e: 1 } }
          class Remove < RecursiveSchemaFilter
            def filter(_, memo, _)
              _recurse_remove(memo, scheme)
              memo
            end

            private

            def _recurse_remove(opts, schm)
              return unless Utils.recursive?(opts)

              if Utils.hashable?(schm)
                _scheme_remove(opts, schm.to_hash)
              elsif Utils.list?(schm)
                _list_remove(opts, schm.to_ary)
              end
            end

            def _list_remove(opts, list)
              list.each { |field| opts.delete(field) }
            end

            def _scheme_remove(opts, schm)
              schm.each_pair do |field, sub_scheme|
                if sub_scheme.nil?
                  opts.delete(field)
                elsif opts.include?(field)
                  _recurse_remove(opts[field], sub_scheme)
                end
              end
            end
          end

          ##
          # Override specified keys in options hash
          #
          # The filter performs merge the hash passed at initialization with
          # options hash. Either hash itself or block returning a hash
          # can be specified. The block will be evaluated in instance context
          # so all instance methods are accessible.
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Contextualized
          #
          #      contextualize filter(:copy) & filter(:override, a: 12, b: 15, c: { d: 30 })
          #    end
          #
          #    i = Piece.new
          #    opts = Options.new(c: { e: 1 })
          #    opts.filter(i.filter) # => { a: 12, b: 15, c: { d: 30, e: 1 } }
          class Override < Filter
            attr_reader :override

            def initialize(override = nil, &override_block)
              @override = _check_override_type(override || override_block)
            end

            def filter(_, memo, instance)
              Utils.merge(
                memo,
                if override.respond_to?(:to_hash)
                  override
                elsif override.respond_to?(:to_proc)
                  instance.instance_eval(&override)
                end
              )
            end

            private

            def _check_override_type(ovrr)
              raise "Wrong override value: #{ovrr.inspect}" unless _proper_override_type?(ovrr)
              ovrr
            end

            def _proper_override_type?(ovrr)
              ovrr.respond_to?(:to_hash) || ovrr.respond_to?(:to_proc)
            end
          end

          ##
          # Chain filters
          #
          # The filter chains all passed filters to have chained
          # filter semantics.
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Contextualized
          #
          #      contextualize filter(:copy) & filter(:remove, :c) & filter(:override, a: 12, b: 15)
          #    end
          #
          #    i = Piece.new
          #    opts = Options.new(c: { e: 1 })
          #    opts.filter(i.filter) # => { a: 12, b: 15 }
          class Chain < Filter
            attr_reader :filters

            def initialize(*flts)
              wrong_objects = flts.reject { |f| f.respond_to?(:to_proc) }
              unless wrong_objects.empty?
                raise(
                  "The following objects are not filters: #{wrong_objects.inspect}"
                )
              end

              @filters = flts
            end

            def filter(options, memo, instance)
              filters.inject(memo) { |acc, elem| instance.instance_exec(options, acc, &elem) }
            end
          end

          ##
          # Chain filters
          def &(other)
            fltr = other.to_filter
            return self if fltr.is_a?(Identity)
            Chain.new(self, fltr)
          end

          ##
          # Creates closure with filter invocation
          #
          # It's an interface method required for Filter to expose
          # functor properties. It encloses invocation of Filter
          # filter method into a closure. The closure itself is
          # executed in the context of Filtered instance which provides
          # proper set "self" variable.
          #
          # The closure itself accepts just one parameter:
          # * +opts+ - input hash to be filtered
          # ...where instance is assumed from self
          def to_proc
            fltr = self
            ->(opts, memo = {}) { fltr.filter(opts, memo, self) }
          end

          ##
          # Filter method
          #
          # * +opts+ - input hash to be filtered
          # * +instance+ - the instance filter is executed in
          def filter(opts, memo, instance); end

          def to_filter
            self
          end
        end

        ##
        # Mixin for filter factory method
        #
        # Adds filter factory method to the target
        module FilterFactory
          ##
          # Filter factory method
          #
          # It creates a filter based on type identifier and parameters with optional block which
          # will be passed unchanged to the filter constructor
          # * +type+ - type identifier; can by either symbol or string
          # * +args+ - filter constructor arguments
          # * +blk+ - optional block to be passed to filter constructor
          def filter(type, *args, &blk)
            Filter.const_get(type.to_s.capitalize).new(*args, &blk)
          end
        end

        ##
        # Class-level mixins
        #
        # It's a DSL extension to declaratively define context filters
        class_scope do
          include FilterFactory
        end

        instance_scope do
          include FilterFactory
        end
      end
    end
  end
end
