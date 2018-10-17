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

            def initialize(definition = nil, &blk)
              @definition = if definition
                definition.extend(&blk)
              else
                Utils::Expressions::Definition.new(&blk)
              end
            end

            protected

            def transform(value, _)
              return if value.nil?
              return _parser.parse(value) if value.respond_to?(:to_str)

              value.to_boxed_expression
            end

            private

            def _parser
              return @_parser if @_parser

              @_parser = Utils::Expressions::Parser.with(definition)
            end
          end
        end
      end
    end
  end
end
