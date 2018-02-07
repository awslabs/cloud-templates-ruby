require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Parametrized
          module Transformations
            ##
            # Float transformation documentation
            #
            # Just prints the blurb since the transformation is not parametrizable.
            class AsFloat < Rdoc::Parametrized::Transformation
              register_in Rdoc
              for_entity Templates::Utils::Parametrized::Transformation::AsFloat

              def provide
                sub(text('to float'))
              end
            end
          end
        end
      end
    end
  end
end
