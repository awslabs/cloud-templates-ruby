require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Parametrized
        class Constraint
          ##
          # Check if value satisfies the condition
          #
          # Checks if value satisfies the condition defined in the block
          # which should return true if the condition is met and false if it's
          # not. If value fails the check, an exception will be thrown
          # with attached condition description. The description is a part
          # of constraint definition.
          #
          # The block is evaluated in the functor's invocation context.
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #      parameter :param1,
          #        :constraint => satisfies('Mediocre value') { |v| v < 100 }
          #    end
          #
          #    i = Piece.new(:param2 => 1)
          #    i.param1 # => 1
          #    i = Piece.new(:param1 => 101)
          #    i.param1 # raise ParameterValueInvalid
          class SatisfiesCondition < self
            attr_reader :condition
            attr_reader :description

            def initialize(description, &cond_block)
              @condition = cond_block
              @description = description
            end

            protected

            def check(parameter, value, instance)
              return if instance.instance_exec(value, &condition)

              raise(
                "#{value.inspect} doesn't satisfy the condition " \
                "#{description} for parameter #{parameter.name}"
              )
            end
          end
        end
      end
    end
  end
end
