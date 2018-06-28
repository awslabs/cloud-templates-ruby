require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Parametrized
          module Transformations
            ##
            # JSON transformation documentation
            #
            # Just prints the documentation blurb.
            class AsJson < Rdoc::Parametrized::Transformation
              for_entity Templates::Utils::Parametrized::Transformation::AsJson

              def provide
                sub(text('to JSON string'))
              end
            end
          end
        end
      end
    end
  end
end
