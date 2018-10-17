require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Expressions
        module Parser
          ##
          # Parser instance
          #
          # Provides a simple binding mechanism between TreeTop-derived parser and syntax nodes and
          # context definition which contains defined variables and functions.
          class Implementation
            attr_reader :parser
            attr_reader :definition

            def initialize(definition, parser)
              @parser = parser
              @definition = definition
            end

            def parse(str)
              result = parser.parse(str)
              raise parser.failure_reason if result.nil?

              result.clean.to_dsl(definition)
            end
          end
        end
      end
    end
  end
end
