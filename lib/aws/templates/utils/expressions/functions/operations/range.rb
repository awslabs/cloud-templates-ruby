require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Expressions
        module Functions
          module Operations
            ##
            # Range comparisons namespace
            #
            # Range comparison expressions accept range as their rvalue. Meaning of the range
            # comparisons is that you are checking if some particular value inside of a range or
            # outside.
            module Range
              ##
              # Basic range comparison
              #
              # Defines parameter types and string formatting.
              class Comparison < Operations::Binary
                include Expressions::Features::Logical

                parameter :value,
                          description: 'Value to be matched',
                          transform: as_boxed_expression,
                          constraint: all_of(
                            not_nil,
                            is?(Expressions::Features::Comparable)
                          )

                parameter :range,
                          description: 'Range',
                          transform: as_boxed_expression,
                          constraint: all_of(
                            not_nil,
                            is?(Expressions::Functions::Range)
                          )

                def to_s
                  str = if value.is_a?(Functions::Operation)
                    "(#{value})"
                  else
                    value
                  end

                  "#{str}#{self.class.op_sign}#{range}"
                end
              end

              ##
              # Inside
              #
              # Example:
              #
              #    dsl.expression { x =~ range(inclusive(1), inclusive(2)) }
              class Inside < Comparison
                sign_as '=~'
              end

              ##
              # Outside
              #
              # Example:
              #
              #    dsl.expression { x !~ range(inclusive(1), inclusive(2)) }
              class Outside < Comparison
                sign_as '!~'
              end
            end
          end
        end
      end
    end
  end
end
