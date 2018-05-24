require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Expressions
        module Functions
          ##
          # Range function
          #
          # The function provides a way to represent value ranges for range comparison operators.
          # Range function contains two arguments which correspond to the lower and upper range
          # boundary respectively.
          #
          # Example:
          #
          #    range(inclusive(1), exclusive(2))
          class Range < Expressions::Function
            name_as 'range'

            ##
            # Border abstract function
            #
            # Range function accept as its' arguments Border functions which represent numeric value
            # of a particular border. Concrete Border classes signal if the border is inclusive or
            # exclusive.
            class Border < Expressions::Function
              ##
              # Inclusive border function
              #
              # Example:
              #
              #    inclusive(2)
              class Inclusive < Border
                name_as :inclusive
              end

              ##
              # Exclusive border function
              #
              # Example:
              #
              #    exclusive(2)
              class Exclusive < Border
                name_as :exclusive
              end

              parameter :value,
                        description: 'Numeric value',
                        transform: as_boxed_expression,
                        constraint: is?(Expressions::Number)

              def unbox
                value.unbox
              end

              def initialize(value)
                super(value)
              end
            end

            parameter :lower,
                      description: 'Lower bound',
                      transform: as_boxed_expression,
                      constraint: is?(Border)

            parameter :upper,
                      description: 'Upper bound',
                      transform: as_boxed_expression,
                      constraint: all_of(
                        is?(Border),
                        satisfies('upper is bigger than lower') { |v| v.unbox > lower.unbox }
                      )

            def initialize(lower, upper)
              super(lower, upper)
            end
          end
        end
      end
    end
  end
end
