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

          def instantiate(name, *args)
            return DEFAULTS[name].new(name, *args) if DEFAULTS.include?(name)
            raise "#{name} is not defined" unless @definitions.include?(name)
            @definitions[name].new(name, *args)
          end

          def defined?(name)
            DEFAULTS.include?(name) || @definitions.include?(name)
          end

          def initialize(spec = nil, &blk)
            @definitions = spec.dup || {}
            instance_eval(&blk) if block_given?
          end

          def extend(spec = nil, &blk)
            return self if spec.nil? && blk.nil?

            new_definitions = if spec.nil?
              definitions
            else
              definitions.merge(spec.is_a?(self.class) ? spec.definitions : spec)
            end

            self.class.new(new_definitions, &blk)
          end

          def dsl(&blk)
            @dsl ||= Expressions::Dsl.new(self)
            @dsl.expression(&blk)
          end

          private

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