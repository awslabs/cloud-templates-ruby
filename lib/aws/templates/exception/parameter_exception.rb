require 'aws/templates/utils'

module Aws
  module Templates
    module Exception
      ##
      # Generic exception happening at parameter invocation
      class ParameterException < RuntimeError
        attr_reader :parameter
        attr_reader :instance

        def initialize(instance, parameter)
          @parameter = parameter
          @instance = instance
          super(custom_message)
        end

        protected

        def custom_message
          "Can't get #{parameter_description}"
        end

        def parameter_description
          description = "#{instance.class}.#{parameter.name} (#{parameter.description})"

          description += " inherited from #{parameter.scope}" if parameter_inherited?

          description += " defined at #{parameter_location}" if parameter.located?

          description
        end

        def parameter_inherited?
          parameter.scoped? && (instance.class != parameter.scope)
        end

        def parameter_location
          parameter.source_location.join(':')
        end
      end
    end
  end
end
