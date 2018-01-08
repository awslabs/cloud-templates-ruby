require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Parametrized
          module Transformations
            ##
            # Render transformation documentation
            #
            # Prints Render type and assigned parameters.
            class AsRendered < Rdoc::Parametrized::Transformation
              for_entity Templates::Utils::Parametrized::Transformation::AsRendered

              def provide
                description = "render with #{context.type}"
                description.concat(" (#{context.parameters})") if context.parameters

                sub(text(description))
              end
            end
          end
        end
      end
    end
  end
end
