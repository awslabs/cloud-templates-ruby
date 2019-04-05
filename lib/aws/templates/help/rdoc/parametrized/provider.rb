require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Parametrized
          ##
          # Parametrized documentation aspect provider
          #
          # Composes documentation blocks of all parameters assigned to the class or its' parents.
          class Provider < Rdoc::Provider
            for_entity Templates::Utils::Parametrized

            def to_processed
              return if context.parameters.empty?

              sub(
                text('_Parameters_'),
                list(:BULLET) do |l|
                  context.parameters.each_value { |parameter| l << processed_for(parameter) }
                end
              )
            end
          end
        end
      end
    end
  end
end
