require 'aws/templates/utils'

module Aws
  module Templates
    module Exception
      ##
      # Invalid parameter specification hash
      #
      # If unknown option is passed in a parameter description block
      class ParameterSpecificationIsInvalid < ParametrizedDSLError
        # Parameter object faulty options were specified for
        attr_reader :parameter

        # Options unknown to Parametrized
        attr_reader :options

        def initialize(target_parameter, opts)
          @parameter = target_parameter
          @options = opts

          super(
            'Unsupported options are in specification for ' \
            "parameter #{target_parameter.name} in class " \
            "#{target_parameter.klass} : #{opts}"
          )
        end
      end
    end
  end
end
