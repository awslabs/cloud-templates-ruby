require 'aws/templates/utils'
require 'polyglot'
require 'treetop'
require 'aws/templates/utils/expressions/parser/grammar'

module Aws
  module Templates
    module Utils
      module Expressions
        ##
        # Parser
        #
        # Parser transforms string representation of expressions into a tree of DSL objects.
        # The output of the parser equals to the one when DSL expressions wrapper is used so both
        # methods are interchangeable.
        #
        # Example:
        #
        #    Parser.with(definition).parse('x + 1')
        module Parser
          def self.with(definition, parser = nil)
            Implementation.new(definition, parser || GrammarParser.new)
          end
        end
      end
    end
  end
end
