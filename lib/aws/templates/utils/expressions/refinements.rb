require 'aws/templates/utils'

using Aws::Templates::Utils::Dependency::Refinements

module Aws
  module Templates
    module Utils
      module Expressions
        ##
        # Boxing-related refiniments
        #
        # Adds flags and transformation methods to the standard classes.
        module Refinements
          refine ::Object do
            def boxable_expression?
              false
            end
          end

          refine ::Numeric do
            def boxable_expression?
              true
            end

            def to_boxed_expression
              Expressions::Number.new(self)
            end
          end

          refine Utils::Dependency::Wrapper do
            def boxable_expression?
              delegate.boxable_expression?
            end

            def to_boxed_expression
              delegate.to_boxed_expression.as_a_dependency.to(self)
            end
          end

          refine ::TrueClass do
            def boxable_expression?
              true
            end

            def boxed_expression?
              true
            end

            def to_boxed_expression
              self
            end
          end

          refine ::FalseClass do
            def boxable_expression?
              true
            end

            def boxed_expression?
              true
            end

            def to_boxed_expression
              self
            end
          end

          refine ::Range do
            def boxable_expression?
              true
            end

            def to_boxed_expression
              Expressions::Range.new(
                Expressions::Range::Inclusive.new(min),
                (
                  exclude_end? ? Expressions::Range::Exclusive : Expressions::Range::Inclusive
                ).new(last)
              )
            end
          end
        end
      end
    end
  end
end
