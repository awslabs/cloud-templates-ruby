require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Expressions
        module Functions
          module Operations
            ##
            # Logical namespace
            #
            # Logical operations are DSL object which embody information about regular logical
            # expressions such as conjunction and disjunction.
            module Logical
              using Expressions::Refinements

              ##
              # Logical concept
              #
              # Concept defines that value should be boxable and should be flagged as Logical
              Concept = Utils::Parametrized::Concept.from do
                {
                  transform: Expressions::Function.as_boxed_expression,
                  constraint: all_of(
                    not_nil,
                    is?(Expressions::Flags::Logical)
                  )
                }
              end

              ##
              # Not
              #
              # Example:
              #
              #    dsl.expression { !a }
              class Not < Operations::Unary
                include Expressions::Features::Logical

                sign_as '!'

                parameter :argument,
                          description: 'Boolean expression to negate',
                          concept: Logical::Concept
              end

              ##
              # Basic binary logical operation
              #
              # It defines parameter types and string formatting.
              class Binary < Operations::Binary
                include Expressions::Features::Logical

                parameter :left,
                          description: 'Left argument',
                          concept: Logical::Concept

                parameter :right,
                          description: 'Right argument',
                          concept: Logical::Concept

                def to_s
                  "#{wrap(left)}#{self.class.op_sign}#{wrap(right)}"
                end

                protected

                def wrap(arg)
                  arg
                end
              end

              ##
              # Or
              #
              # Example:
              #
              #    dsl.expression { a | b }
              class Or < Binary
                sign_as '|'
              end

              ##
              # And
              #
              # Example:
              #
              #    dsl.expression { a & b }
              class And < Binary
                sign_as '&'

                protected

                def wrap(arg)
                  arg.is_a?(Or) ? "(#{super})" : super
                end
              end
            end
          end
        end
      end
    end
  end
end
