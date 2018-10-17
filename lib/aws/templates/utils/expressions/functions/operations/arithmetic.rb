require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Expressions
        module Functions
          module Operations
            module Arithmetic
              ##
              # Negation
              #
              # Example:
              #
              #    dsl.expression { -x }
              class Negative < Operations::Unary
                include Expressions::Features::Arithmetic

                sign_as '-'

                parameter :argument,
                          description: 'Value to be negated',
                          transform: as_boxed_expression,
                          constraint: all_of(
                            not_nil,
                            is?(Expressions::Features::Arithmetic)
                          )
              end

              # Arithmetic operation with two arguments
              class Binary < Operations::Binary
                include Expressions::Features::Arithmetic

                parameter :left,
                          description: 'Left argument',
                          transform: as_boxed_expression,
                          constraint: all_of(
                            not_nil,
                            is?(Expressions::Features::Arithmetic)
                          )

                parameter :right,
                          description: 'Right argument',
                          transform: as_boxed_expression,
                          constraint: all_of(
                            not_nil,
                            is?(Expressions::Features::Arithmetic)
                          )
              end

              ##
              # Additive operation
              #
              # Additive operations share the same priority and argument wrapping condition
              class Additive < Binary
                protected

                def wrap(arg)
                  return "(#{arg})" if arg.is_a?(Operations::Unary)

                  arg
                end
              end

              ##
              # Addition
              #
              # Example:
              #
              #    dsl.expression { x + 1 }
              class Addition < Additive
                sign_as '+'
              end

              ##
              # Subtraction
              #
              # Example:
              #
              #    dsl.expression { x - 1 }
              class Subtraction < Additive
                sign_as '-'
              end

              ##
              # Multiplicative operation
              #
              # Multiplicative operations share the same priority and argument wrapping condition
              class Multiplicative < Binary
                protected

                def wrap(arg)
                  return super unless arg.is_a?(Expressions::Functions::Operation)

                  arg.is_a?(Multiplicative) ? super : "(#{super})"
                end
              end

              ##
              # Multiplication
              #
              # Example:
              #
              #    dsl.expression { x * y }
              class Multiplication < Multiplicative
                sign_as '*'
              end

              ##
              # Division
              #
              # Example:
              #
              #    dsl.expression { x / y }
              class Division < Multiplicative
                sign_as '/'
              end
            end
          end
        end
      end
    end
  end
end
