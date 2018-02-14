require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Parametrized
          module Transformations
            ##
            # Parse transformation documentation
            #
            # Prints Parser type and assigned parameters.
            class AsParsed < Rdoc::Parametrized::Transformation
              for_entity Templates::Utils::Parametrized::Transformation::AsParsed

              def provide
                description = "parse with #{context.parser.class}"
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
