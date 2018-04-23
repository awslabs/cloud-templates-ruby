require 'aws/templates/utils'

module Aws
  module Templates
    module Exception
      ##
      # Getter exception
      #
      # Happens during runtime if an error happens during value extraction
      class ParameterGetterException < ParameterRuntimeException
        # Getter object
        attr_reader :getter

        def initialize(getter)
          @getter = getter
          super "can't get value (#{getter} getter)"
        end
      end
    end
  end
end
