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
              for_entity Templates::Utils::Parametrized::Transformation::AsFloat

              def to_processed
                sub(text('to float'))
              end
            end
          end
        end
      end
    end
  end
end
