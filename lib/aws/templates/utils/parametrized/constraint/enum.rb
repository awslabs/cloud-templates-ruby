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
            attr_reader :set

            def initialize(list)
              @set = Set.new(list)
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
