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
          class Provider < Rdoc::Inheritable
            for_entity Templates::Utils::Parametrized

            header 'Parameters'

            protected

            def description_for(mod)
              return if mod.parameters.empty?

              list do |l|
                mod.parameters
                   .each_value { |parameter| l << processed_for(parameter) }
              end
            end
          end
        end
      end
    end
  end
end
