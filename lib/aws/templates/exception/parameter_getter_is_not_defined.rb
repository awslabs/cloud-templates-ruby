require 'aws/templates/utils'

module Aws
  module Templates
    module Exception
      ##
      # Getter is not specified
      #
      # Getter wasn't specified neither for the individual parameter nor for the mixing instance nor
      # for its class.
      class ParameterGetterIsNotDefined < ParameterException
        def initialize(target_parameter)
          super(
            target_parameter,
            "Can't find getter for #{target_parameter.name} (#{target_parameter.description}): " \
              'a getter should be attached either to the parameter or the instance ' \
              'or the instance class'
          )
        end
      end
    end
  end
end
