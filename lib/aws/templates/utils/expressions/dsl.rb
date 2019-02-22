require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Expressions
        ##
        # DSL wrapper
        #
        # With "expression" method of the wrapper you are able to write expressions in plain Ruby.
        # DSL requires an instance of Definition to be initialized.
        #
        # Example:
        #
        #    dsl = Aws::Templates::Utils::Expressions::Dsl.new(definition)
        class Dsl
          attr_reader :definition

          def method_missing(name, *args)
            definition.defined?(name) ? definition.instantiate(name, *args) : super
          end

          def respond_to_missing?(name, include_private = false)
            definition.defined?(name) || super
          end

          def expression(&blk)
            instance_eval(&blk)
          end

          def initialize(definition)
            @definition = definition
          end
        end
      end
    end
  end
end
