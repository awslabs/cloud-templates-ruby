require 'aws/templates/utils'

module Aws
  module Templates
    module Exception
      ##
      # Getter is not specified
      #
      # Getter wasn't specified neither for the individual parameter nor for the mixing instance nor
      # for its class.
      class ParameterGetterIsNotDefined < ParameterProcessingException
        protected

        def custom_message
          "Can't find getter for #{parameter_description}: a getter should be attached either " \
            'to the parameter or the instance or the class'
        end
      end
    end
  end
end
