require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Parametrized
        class Constraint
          ##
          # Check if passed value is not nil
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #
          #      parameter :param1, :constraint => not_nil
          #    end
          #
          #    i = Piece.new(:param1 => 3)
          #    i.param1 # => 3
          #    i = Piece.new
          #    i.param1 # throws ParameterValueInvalid
          class NotNil < self
            def initialize
              self.if(Constraint::Condition.any)
            end

            protected

            def check(value, _)
              raise('required but was not found in input hash') if value.nil?
            end
          end
        end
      end
    end
  end
end
