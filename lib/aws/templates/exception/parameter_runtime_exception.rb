require 'aws/templates/utils'

module Aws
  module Templates
    module Exception
      ##
      # Parameter exception
      #
      # Generic runtime exception in the framework evaluation
      class ParameterRuntimeException < RuntimeError
      end
    end
  end
end
