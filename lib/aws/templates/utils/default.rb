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
        # Hash wrapper
        #
        # The hash wrapper does intermediate calculations of nested lambdas in the specified
        # context as they are encountered
        class Definition
          ##
          # Definition entry point
          def entry
            _process_value(@entry)
          end

          ##
          # Defined hash keys
          def keys
            entry.keys
          end

          ##
          # Transform to hash
          def to_hash
            _recurse_into(entry)
          end

          def dependency?
            true
          end

          def dependencies
            to_hash.dependencies
          end

          ##
          # Index operator
          #
          # Performs intermediate transformation of value if needed (if value is a lambda) and
          # returns it wrapping into Definition instance with the same context if needed
          # (if value is a map)
          def [](k)
            result = _process_value(entry[k])
            result.respond_to?(:to_proc) ? self.class.new(result, @context) : result
          end

          ##
          # Check if the key is present in the hash
          def include?(k)
            entry.include?(k)
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
            @entry = ent
            @context = ctx
          end

          private

          def _process_value(value)
            if value.respond_to?(:to_hash)
              value
            elsif value.respond_to?(:to_proc)
              @context.instance_eval(&value)
            else
              value
            end
          end

          def _recurse_into(value)
            value.each_with_object({}) do |(k, v), memo|
              processed = _process_value(v)
              processed = _recurse_into(processed.to_hash) if Utils.hashable?(processed)
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
            # iterating through all ancestors with defaults
            ancestors_with_defaults.inject(Utils::Options.new) do |opts, mod|
              mod.defaults.inject(opts) do |acc, defaults_definition|
                acc.merge!(Definition.new(defaults_definition, self))
              end
            end
          end

          private

          def ancestors_with_defaults
            self
              .class
              .ancestors
              .select { |mod| (mod != Default) && mod.ancestors.include?(Default) }
              .reverse!
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
            Aws::Templates::Utils::DELETED_MARKER
          end

          ##
          # Defaults for the input hash
          #
          # Class-level accessor of a hash which will be merged into input
          # parameters hash. The hash can't be changed directly or set to
          # another value. Only incremental changes are allowed with
          # default method which is a part of the framework DSL. The method
          # returns only defaults for the current class without
          # consideration of the class hierarchy.
          def defaults
            @defaults ||= []
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

            unless param.respond_to?(:to_hash) || param.respond_to?(:to_proc)
              raise_default_type_mismatch(
                param
              )
            end

            defaults << param
          end

          def raise_defaults_is_nil
            raise ArgumentError.new('Map should be specified')
          end

          def raise_default_type_mismatch(defaults_hash)
            raise ArgumentError.new("#{defaults_hash.inspect} is not a hash or a proc")
          end
        end
      end
    end
  end
end
