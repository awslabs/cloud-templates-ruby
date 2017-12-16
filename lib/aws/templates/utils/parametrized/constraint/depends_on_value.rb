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
            ##
            # Selector hash
            attr_reader :selector

            def initialize(selector)
              @selector = selector
              self.if(Parametrized.any)
            end

            protected

            def check(parameter, value, instance)
              return unless selector.key?(value)

              instance.instance_exec(
                parameter,
                value,
                &selector[value]
              )
            end
          end
        end
      end
    end
  end
end
