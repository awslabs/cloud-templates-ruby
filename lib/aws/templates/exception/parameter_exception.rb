require 'aws/templates/utils'

module Aws
  module Templates
    module Exception
      ##
      # Parameter exception
      #
      # Happens during runtime if an error happens during parameter
      # evaluation
      class ParameterException < RuntimeError
        # Parameter object
        attr_reader :parameter

        def message
          cause.nil? ? super : "#{super} : #{cause.message}"
        end

        def initialize(target_parameter, custom_message)
          @parameter = target_parameter
          super(custom_message)
        end
      end
    end
  end
end
