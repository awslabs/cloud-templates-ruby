require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Expressions
        module Functions
          module Operations
            ##
            # Comparisons namespace
            #
            # Comparisons are DSL objects which embody information about comparison operations.
            module Comparisons
              ##
              # Basic comparison class
              #
              # It defines arguments checking and string formatting
              class Comparison < Operations::Binary
                include Expressions::Features::Logical

                parameter :left,
                          description: 'Left argument',
                          transform: as_boxed_expression,
                          constraint: all_of(
                            not_nil,
                            is?(Expressions::Features::Comparable)
                          )

                parameter :right,
                          description: 'Right argument',
                          transform: as_boxed_expression,
                          constraint: all_of(
                            not_nil,
                            is?(Expressions::Features::Comparable)
                          )

                protected

                def wrap(arg)
                  return "(#{arg})" if arg.is_a?(Functions::Operation)
                  arg
                end
              end

              ##
              # Greater
              #
              # Example:
              #
              #    dsl.expression { x > 1 }
              class Greater < Comparison
                sign_as '>'
              end

              ##
              # Greater or equal
              #
              # Example:
              #
              #    dsl.expression { x > =1 }
              class GreaterOrEqual < Comparison
                sign_as '>='
              end

              ##
              # Less
              #
              # Example:
              #
              #    dsl.expression { x < 1 }
              class Less < Comparison
                sign_as '<'
              end

              ##
              # Less or equal
              #
              # Example:
              #
              #    dsl.expression { x <= 1 }
              class LessOrEqual < Comparison
                sign_as '<='
              end

              ##
              # Equal
              #
              # Example:
              #
              #    dsl.expression { x == 1 }
              class Equal < Comparison
                sign_as '=='
              end

              ##
              # Greater
              #
              # Example:
              #
              #    dsl.expression { x != 1 }
              class NotEqual < Comparison
                sign_as '!='
              end
            end
          end
        end
      end
    end
  end
end
