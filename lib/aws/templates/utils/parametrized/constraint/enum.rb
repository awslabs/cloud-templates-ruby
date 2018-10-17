require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Parametrized
        class Constraint
          ##
          # Check if passed value is in the enumeration values.
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #
          #      parameter :param1, :constraint => enum([1,'2',3])
          #    end
          #
          #    i = Piece.new(:param1 => 3)
          #    i.param1 # => 3
          #    i = Piece.new(:param1 => 4)
          #    i.param1 # throws ParameterValueInvalid
          class Enum < self
            using Parametrized::Transformation::Refinements

            attr_reader :set

            def initialize(*list)
              @set = ::Set.new(list.flatten(1))
            end

            def satisfied_by?(other)
              return false unless other.is_a?(self.class)

              set >= other.set
            end

            def transform_as(transform, instance)
              self.class.new(*(set.map { |option| instance.instance_exec(option, &transform) }))
            end

            protected

            def check(value, _)
              return if set.include?(value)

              raise "Value #{value.inspect} is not in the set of allowed values #{set.inspect}"
            end
          end
        end
      end
    end
  end
end
