require 'aws/templates/utils'

module Aws
  module Templates
    module Exception
      ##
      # Constraint exception
      #
      # Happens during runtime if an error happens during constraint checking
      class ParameterConstraintException < ParameterValueException
        protected

        def custom_message
          "#{value.inspect} failed constraint #{operation_description}"
        end
      end
    end
  end
end
