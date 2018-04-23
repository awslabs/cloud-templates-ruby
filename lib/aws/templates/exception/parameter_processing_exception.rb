require 'aws/templates/utils'

module Aws
  module Templates
    module Exception
      ##
      # Exception happening during parameter value extraction and checking stage
      class ParameterProcessingException < ParameterException
      end
    end
  end
end
