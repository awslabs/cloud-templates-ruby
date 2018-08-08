require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Parametrized
        class Transformation
          ##
          # Parse the value
          #
          # The transformation can be considered is a reverse of AsRendered. It parses input string
          # according to specified grammar parser and returns the result. The supported parser API
          # is the one of TreeTop generated parsers.
          #
          # === Example
          #
          #    require 'expression_grammar'
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #
          #      parameter :expression, :transform => as_parsed(ExpressionGrammarParser)
          #    end
          #
          #    i = Piece.new(expression: 'x > 1')
          #    i.expression # => <parsed>
          class AsParsed < self
            attr_reader :parser
            attr_reader :parameters

            def initialize(parser, parameters = nil, &parameters_block)
              @parser = parser.is_a?(Class) ? parser.new : parser
              @parameters = parameters || parameters_block
            end

            protected

            def transform(value, instance)
              return if value.nil?
              _parse(value, instance)
            end

            private

            def _parse(value, instance)
              result = parser.parse(value.to_s, _compute_parser_parameters(instance))
              raise parser.failure_reason if result.nil?
              result
            end

            def _compute_parser_parameters(instance)
              return {} if parameters.nil?

              if parameters.respond_to?(:to_hash)
                parameters
              elsif parameters.respond_to?(:to_proc)
                instance.instance_exec(&parameters)
              else
                parameters
              end
            end
          end
        end
      end
    end
  end
end
