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
            def boxed_expression?
              false
            end

            def to_expression_by(definition)
              definition.cast_for(self)
            end
          end

          refine ::String do
            def to_expression_by(definition)
              Expressions::Parser.with(definition).parse(self)
            end
          end

          refine ::Proc do
            def to_expression_by(definition)
              Expressions::Dsl.new(definition).expression(&self)
            end
          end

          refine Utils::Dependency::Wrapper do
            using Aws::Templates::Utils::Dependency::Refinements

            def to_expression_by(definition)
              object.to_expression_by(definition).as_a_dependency.to(self)
            end
          end
        end
      end
    end
  end
end
