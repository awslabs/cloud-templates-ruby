require 'aws/templates/utils'

module Aws
  module Templates
    module Exception
      ##
      # Transformation exception
      #
      # Happens during runtime if an error happens during transformation
      class ParameterTransformException < ParameterValueException
        protected

        def custom_message
          "can't transform #{value.inspect} with #{operation_description}"
        end
      end
    end
  end
end
