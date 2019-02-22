require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Expressions
        ##
        # DSL definition
        #
        # It's a container for function and variable definitions which are allowed in a particular
        # instance. It's also a factory for Variable and Function instances. The factory method
        # is invoked by either DSL module or Parser.
        class Definition
          attr_reader :definitions
          attr_reader :context

          DEFAULTS = {
            range: Expressions::Functions::Range,
            inclusive: Expressions::Functions::Range::Border::Inclusive,
            exclusive: Expressions::Functions::Range::Border::Exclusive
          }.freeze

          def variables(map)
            raise "#{map} is not a hash" unless map.respond_to?(:to_hash)

            @definitions.merge!(map.to_hash)
          end

          def function(spec = nil, &blk)
            func = _transform_to_function_class(spec, &blk)
            @definitions[func.function_name] = func
          end

          def macro(name, &body)
            raise 'Macros must have name' unless name
            raise 'Macros must have body' unless body

            @definitions[name] = body
          end

          def instantiate(name, *args)
            return _instantiate(DEFAULTS[name], name, args) if DEFAULTS.include?(name)
            return context.send(name, *args) if context.respond_to?(name)
            raise "#{name} is not defined" unless @definitions.include?(name)

            _instantiate(@definitions[name], name, args)
          end

          def defined?(name)
            DEFAULTS.include?(name) || @context.respond_to?(name) || @definitions.include?(name)
          end

          def initialize(spec = nil, context = nil, &blk)
            @definitions = spec.nil? ? {} : spec.dup
            @context = context
            instance_exec(context, &blk) if block_given?
          end

          def extend(spec = nil, context = nil, &blk)
            self.class.new(definitions, context, &blk).extend!(spec)
          end

          def extend!(spec = nil, context = nil, &blk)
            return self if spec.nil? && blk.nil?

            definitions.merge!(spec.is_a?(self.class) ? spec.definitions : spec) unless spec.nil?
            instance_exec(context, &blk) if block_given?

            self
          end

          def dsl(&blk)
            @dsl ||= Expressions::Dsl.new(self)
            @dsl.expression(&blk)
          end

          private

          def _instantiate(obj, name, args)
            if obj.is_a?(Module)
              obj.instantiate(name, *args)
            elsif obj.respond_to?(:to_proc)
              instance_exec(*args, &obj)
            else
              raise "Not a supported definition #{obj.inspect}"
            end
          end

          def _transform_to_function_class(spec, &blk)
            return spec if spec.is_a?(::Class)

            if spec.respond_to?(:to_sym)
              Expressions::Function.with(spec.to_sym, &blk)
            elsif spec.respond_to?(:to_hash)
              _define_function_from_hash(spec, &blk)
            else
              raise "#{spec} is not a function definition"
            end
          end

          def _define_function_from_hash(spec, &blk)
            raise "#{spec} is not a hash" unless spec.respond_to?(:to_hash)

            hsh = spec.to_hash
            raise "#{hsh} definition format should be <name>: <type>" unless spec.size == 1

            type = hsh.values.first
            raise "#{type} is not a type" unless type.is_a?(::Module)

            name = hsh.keys.first.to_sym

            Expressions::Function.with(name, type, &blk)
          end
        end
      end
    end
  end
end
