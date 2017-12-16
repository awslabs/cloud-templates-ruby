require 'aws/templates/utils'

module Aws
  module Templates
    module Exception
      ##
      # Parameter already exists
      #
      # If you're trying to define a parameter in a parametrized artifact
      # and this parameter either already defined for the class or defined
      # in an ancestor.
      class ParameterAlreadyExist < ParametrizedDSLError
        # Parameter object of the conflicting parameter
        attr_reader :parameter

        def initialize(target_parameter)
          @parameter = target_parameter
          super(
            "Parameter #{target_parameter.name} already in " \
            "#{target_parameter.klass}."
          )
        end
      end
    end
  end
end
