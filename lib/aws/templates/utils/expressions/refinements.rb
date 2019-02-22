require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Expressions
        ##
        # Boxing-related refiniments
        #
        # Adds flags and transformation methods to the standard classes.
        module Refinements
          refine ::BasicObject do
            def boxable_expression?
              false
            end

            def to_expression_by(_)
              to_boxed_expression
            end
          end

          refine ::String do
            def to_expression_by(definition)
              Expressions::Parser.with(definition).parse(self)
            end

            def boxable_expression?
              true
            end

            def to_boxed_expression
              copy = dup

              class <<copy
                include Expressions::Expression
              end

              copy
            end
          end

          refine ::Proc do
            def to_expression_by(definition)
              Expressions::Dsl.new(definition).expression(&self)
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
            using Aws::Templates::Utils::Dependency::Refinements

            def boxable_expression?
              object.boxable_expression?
            end

            def to_boxed_expression
              object.to_boxed_expression.as_a_dependency.to(self)
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
