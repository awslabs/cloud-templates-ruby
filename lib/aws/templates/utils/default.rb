require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      ##
      # Default mixin.
      #
      # It implements class instance-based definitions of so-called
      # defaults. Defaults are input hash alterations and transformations
      # which are defined per-class basis and applied according to class
      # hierarchy when invoked. The target mixing entity should be either
      # Module or Class. In the former case it's possible to model set of
      # object which have common traits organized as an arbitrary graph
      # with many-to-many relationship.
      module Default
        include Aws::Templates::Utils::Inheritable

        ##
        # Functionality-specific refinements
        module Refinements
          refine ::Object do
            ##
            # If the object can be considered a defaults override
            #
            # It is the one which can't be merged with existing defaults layers
            def override?
              respond_to?(:to_sym) || !(respond_to?(:to_proc) || Utils.recursive?(self))
            end

            ##
            # Transform object to defaults definition.
            def to_definition
              Definition.from(self)
            end
          end
        end

        using Refinements

        ##
        # Abstract defaults definition
        #
        # Defaults definition is an object wrapper which enables definition merging. It also
        # contains factory method to transform arbitrary objects into Definition object and defines
        # basic functionality.
        class Definition
          ##
          # Empty definition
          #
          # Doesn't mutate definition in any way. Tries to elliminate itself from the chain
          # of merges.
          class Empty < Definition
            include ::Singleton

            def for(_)
              {}
            end

            def merge(other)
              other.to_definition
            end
          end

          ##
          # Scalar definition
          #
          # Scalar definition overrides everything before it and can be overriden by anything
          # after it.
          class Scalar < Definition
            attr_reader :value

            def initialize(value)
              @value = value
            end

            def for(_)
              value
            end

            def merge(other)
              other.to_definition
            end

            def override?
              true
            end
          end

          ##
          # Definition with scheme
          #
          # Scheme definition can be merged without stacking layers with any other scheme
          # definition. Internal schemes will be merged together producing aggregated scheme.
          # Otherwise, the definition is wither overriden with Scalar or stacked together with
          # Calculable.
          class Scheme < Definition
            attr_reader :scheme

            def initialize(scheme)
              @scheme = scheme
            end

            def merge(other)
              if other.is_a? self.class
                merge(other.scheme)
              elsif Utils.recursive?(other)
                self.class.new(Utils.merge(scheme, other) { |left, right| _merge(left, right) })
              else
                super(other)
              end
            end

            def for(_)
              scheme
            end

            private

            def _merge(one, another)
              one.override? || another.override? ? another : one.to_definition.merge(another)
            end
          end

          ##
          # Lazy-calculated definition
          #
          # Contains functor object which will be evaluated only during actual value look-up
          class Calculable < Definition
            include Utils::Guarded

            attr_reader :block

            def initialize(block)
              @block = block
            end

            def for(instance)
              guarded_for(instance, block) { _process_value(block, instance) }
            end

            private

            def _process_value(value, instance)
              return value if value.override? || Utils.recursive?(value)

              _process_value(instance.instance_eval(&value), instance)
            end
          end

          ##
          # Definition composition
          #
          # Pair of definitions which act like one.
          class Pair < Definition
            class << self
              def [](one, another)
                return another if another.override? || one.override? || one == Definition.empty
                return one if another.nil? || another == Definition.empty

                _unite(one, another)
              end

              private

              def _unite(one, another)
                if one.is_a?(self)
                  new(one.one, one.another.merge(another))
                elsif another.is_a?(self)
                  new(one.merge(another.one), another.another)
                else
                  new(one, another)
                end
              end
            end

            attr_reader :one
            attr_reader :another

            def initialize(one, another)
              @one = one.to_definition
              @another = another.to_definition
            end

            def for(instance)
              eval_b = another.for(instance)
              return eval_b if eval_b.override? && !eval_b.nil?

              eval_a = one.for(instance)
              return eval_b if eval_a.override?

              eval_a.to_definition.merge(eval_b).for(instance)
            end
          end

          class << self
            def empty
              Empty.instance
            end

            def from(obj)
              return obj if obj.is_a? Definition
              return Scalar.new(obj) if obj.override?
              return Scheme.new(obj) if Utils.recursive?(obj)
              return Calculable.new(obj) if obj.respond_to?(:to_proc)

              raise "Invalid object #{obj}"
            end
          end

          def merge(another)
            return another if another.override?
            return self if another == Definition.empty

            Pair[self, another]
          end

          def for(_)
            raise 'Must be overriden'
          end

          def to_definition
            self
          end

          def override?
            false
          end
        end

        ##
        # Hash wrapper
        #
        # The hash wrapper does intermediate calculations of nested lambdas in the specified
        # context as they are encountered
        class Instantiation
          def value
            return @value if @value

            @value = @entry.to_definition.for(@context)
            raise "#{@value.inspect} is not recursive" if @value.override?

            @value
          end

          ##
          # Defined hash keys
          def keys
            value.keys
          end

          ##
          # Transform to hash
          def to_hash
            _recurse_into(value)
          end

          def dependency?
            true
          end

          def links
            to_hash.links
          end

          ##
          # Index operator
          #
          # Performs intermediate transformation of value if needed (if value is a lambda) and
          # returns it wrapping into Definition instance with the same context if needed
          # (if value is a map)
          def [](key)
            result = _process_value(value[key])
            Utils.recursive?(result) ? _new(result) : result
          end

          ##
          # Check if the key is present in the hash
          def include?(key)
            value.include?(key)
          end

          # The class already supports recursive concept so return self
          def to_recursive
            self
          end

          ##
          # Create wrapper object
          #
          # Creates wrapper object with attached hash and context to evaluate lambdas in
          def initialize(ent, ctx)
            raise "#{ent.inspect} is not recursive" if ent.override?

            @entry = ent
            @context = ctx
          end

          private

          def _process_value(value)
            value.override? || Utils.recursive?(value) ? value : value.to_definition.for(@context)
          end

          def _new(ent)
            self.class.new(ent, @context)
          end

          def _recurse_into(value)
            value.keys.each_with_object({}) do |k, memo|
              processed = _process_value(value[k])
              processed = _recurse_into(processed) if Utils.recursive?(processed)
              memo[k] = processed
            end
          end
        end

        instance_scope do
          ##
          # Apply specified defaults to options
          #
          # It's a mixin method which depends on presence of options accessor
          # methods in the consuming class. The options property should contain
          # an object implementing to_hash method. The method is mutating for
          # options. The algorithm is to walk down the hierarchy of the
          # class and collect and merge all defaults from its ancestors
          # prioritizing the ones made later in the class hierarchy. The method
          # is working correctly with both parent classes and all Default
          # mixins used in between.
          def defaults
            Instantiation.new(self.class.defaults_definition, self)
          end
        end

        ##
        # Class-level mixins
        #
        # It's a DSL extension to declaratively define defaults
        class_scope do
          ##
          # To mark hash branch as deleted
          def deleted
            Aws::Templates::Utils::DeletedMarker
          end

          ##
          # Module's specific defaults
          #
          # The defaults defined in this module and not its' ancestors.
          def module_defaults_definition
            @module_defaults_definition || Definition.empty
          end

          ##
          # Defaults for the input hash
          #
          # Class-level accessor of a definition of defaults which will be merged into input
          # parameters hash. The definition can't be changed directly or set to another value.
          # Only incremental changes are allowed with default method which is a part of the
          # framework DSL. The method returns accumulated defaults of all ancestors of the module
          # in one single definition object
          def defaults_definition
            return @defaults if @defaults

            @defaults = ancestors_with(Default)
                        .inject(Definition.empty) do |acc, elem|
                          acc.merge(elem.module_defaults_definition)
                        end
          end

          ##
          # Put an default/calculation for the input hash
          #
          # The class method is the main knob which is used to build
          # hierarchical hash mutation pipeline using language-provided
          # features such as class inheritance and introspection. You can
          # specify either hash (or an object which has :to_hash method) or
          # a lambda/Proc as a parameter.
          #
          # If you specify a hash then it will be merged with the current
          # value of default where the hash passed will take preference
          # during the merge.
          #
          # If you specify a lambda it will be added to calculations stack
          #
          # If the parameter you passed is neither a hash nor callable or
          # no parameters are passed at all, ArgumentError will be thrown.
          def default(param)
            raise_defaults_is_nil unless param
            raise_default_type_mismatch(param) if param.override?

            @module_defaults_definition = module_defaults_definition.to_definition.merge(param)
          end

          def raise_defaults_is_nil
            raise ArgumentError.new('Map should be specified')
          end

          def raise_default_type_mismatch(defaults_hash)
            raise ArgumentError.new("#{defaults_hash.inspect} is not recursive or proc")
          end
        end
      end
    end
  end
end
