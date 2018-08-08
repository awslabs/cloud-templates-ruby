require 'aws/templates/utils'

module Aws
  module Templates
    module Exception
      ##
      # Late bound value processing exception
      #
      # Happens during runtime if type or constraint mismatch occurs during late bound value
      # processing
      class ParameterLateBoundException < ParameterValueException
        attr_reader :clarification

        def initialize(operation, instance, value, clarification)
          @clarification = clarification
          super(operation, instance, value)
        end

        protected

        def custom_message
          "#{clarification} : #{super}"
        end
      end
    end
  end
end
