require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Parametrized
        class Transformation
          ##
          # Transform value into a boxed "expression"
          #
          # Input can be either a boxable expression or a parsable string which can be transformed
          # into a boxable expression.
          #
          # === Example
          #
          #    Context = Definition.new {
          #      variables x: Variables::Arithmetic,
          #                y: Variables::Arithmetic
          #
          #      function(b: Features::Logical) { parameter :a, constraint: not_nil }
          #    }
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #
          #      parameter :expression, transform: as_expression(Context)
          #    end
          #
          #    i = Piece.new(expression: 'x > 1')
          #    i.expression # => <expression>
          class AsExpression < self
            using Utils::Expressions::Refinements

            attr_reader :definition
            attr_reader :extender

            def initialize(definition = nil, &blk)
              @extender = blk
              @definition = definition || Utils::Expressions::Definition.new
            end

            protected

            def transform(value, instance)
              return if value.nil?

              value.to_expression_by(_definition_within(instance))
            end

            private

            def _definition_within(instance)
              extender.nil? ? definition : definition.extend(nil, instance, &extender)
            end
          end
        end
      end
    end
  end
end
