require 'aws/templates/utils'

module Aws
  module Templates
    module Exception
      ##
      # A value failed constraints
      class ParameterValueInvalid < ParameterException
        attr_reader :value
        attr_reader :object

        def initialize(target_parameter, target_object, target_value)
          @value = target_value
          @object = target_object
          super(
            target_parameter,
            message_text(target_parameter, target_object, target_value)
          )
        end

        private

        def message_text(target_parameter, target_object, target_value)
          message = "Value '(#{target_value.inspect})' violates constraints specified for " \
            "#{target_parameter.name} (#{target_parameter.description}) in " \
            "#{target_parameter.klass}"

          unless target_object.class == target_parameter.klass
            message += " and inherited by #{target_object.class}"
          end

          message
        end
      end
    end
  end
end
