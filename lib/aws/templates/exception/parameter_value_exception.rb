require 'aws/templates/utils'

module Aws
  module Templates
    module Exception
      ##
      # Exception in parameter value processing pipeline
      class ParameterValueException < ParameterRuntimeException
        # Functor which was executed for the value which caused the exception
        attr_reader :operation

        # Instance in the context of we are performing parameter calculation
        attr_reader :instance

        # The original value we were processing
        attr_reader :value

        def initialize(operation, instance, value)
          @instance = instance
          @value = value
          @operation = operation

          super(custom_message)
        end

        protected

        def custom_message
          "can't perform #{operation_description} on #{value.inspect}"
        end

        def operation_description
          description = operation.to_s
          description += " defined at #{operation_location}" if operation.located?
          description += " (class #{operation.scope})" if operation.scoped?
          description
        end

        def operation_location
          operation.source_location.join(':')
        end
      end
    end
  end
end
