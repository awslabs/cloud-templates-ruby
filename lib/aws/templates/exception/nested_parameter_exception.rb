require 'aws/templates/utils'

module Aws
  module Templates
    module Exception
      ##
      # If something happens during parameter calculation
      class NestedParameterException < ParameterException
        def initialize(target_parameter)
          super(
            target_parameter,
            'Exception was thrown by nested parameter while calculating ' \
              "#{target_parameter.name} (#{target_parameter.description})"
          )
        end
      end
    end
  end
end
