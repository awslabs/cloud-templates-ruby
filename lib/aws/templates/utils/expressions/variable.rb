require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Expressions
        ##
        # Generic variable
        #
        # Contains variable "definition" (which is usually variable name) and includes basic
        # mixins to behave like expression.
        class Variable
          include Expressions::Expression
          include Utils::Equalizable

          attr_reader :definition

          def equal_to?(other)
            definition == other.definition
          end

          def to_s
            definition.to_s
          end

          def self.instantiate(name)
            new(name)
          end

          def initialize(definition)
            @definition = definition
          end
        end
      end
    end
  end
end
