require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Parametrized
        class Constraint
          ##
          # Switch-like variant check
          #
          # Recursive check implementing switch-based semantics for defining
          # checks need to be performed depending on parameter's value.
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #      parameter :param2
          #      parameter :param1,
          #        :constraint => depends_on_value(
          #          1 => lambda { |v| raise 'Too big' if param2 > 3 },
          #          2 => lambda { |v| raise 'Too small' if param2 < 2 }
          #        )
          #    end
          #
          #    i = Piece.new(:param1 => 1, :param2 => 1)
          #    i.param1 # => 1
          #    i = Piece.new(:param1 => 1, :param2 => 5)
          #    i.param1 # raise ParameterValueInvalid
          #    i = Piece.new(:param1 => 2, :param2 => 1)
          #    i.param1 # raise ParameterValueInvalid
          #    i = Piece.new(:param1 => 2, :param2 => 5)
          #    i.param1 # => 2
          class DependsOnValue < self
            include Utils::Schemed

            using Parametrized::Transformation::Refinements
            using Constraint::Refinements

            def initialize(*args)
              super
              self.if(Constraint::Condition.any)
            end

            def check_schema(schema)
              schema.each_value.reject(&:nil?).each do |c|
                raise "#{c.inspect}(#{c.class}) is not a proc" unless c.respond_to?(:to_proc)
              end
            end

            def satisfied_by?(other)
              return false unless other.is_a?(self.class)

              other_schema = other.schema
              schema_keys_set = schema.keys.to_set
              other_schema_keys_set = other_schema.keys.to_set

              return false if schema_keys_set < other_schema_keys_set

              if schema_keys_set >= other_schema_keys_set
                other_schema.all? { |value, constraint| constraint.satisfies?(schema[value]) }
              else
                return false
              end
            end

            def transform_as(transform, instance)
              transformed = Hash[
                schema
                  .map do |k, v|
                    [instance.instance_exec(k, &transform), instance.instance_exec(v, &transform)]
                  end
              ]

              return if transformed.empty?

              self.class.new(transformed)
            end

            protected

            def check(value, instance)
              unless schema.key?(value)
                return if value.nil?
                raise "#{value.inspect} not present in selector"
              end

              instance.instance_exec(value, &schema[value])
            end
          end
        end
      end
    end
  end
end
