require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Parametrized
          module Transformations
            ##
            # String transformation documentation
            #
            # Just prints the documentation blurb since the transformation is not parametrizable.
            class AsString < Rdoc::Parametrized::Transformation
              for_entity Templates::Utils::Parametrized::Transformation::AsRendered

              def provide
                sub(text('to string'))
              end
            end
          end
        end
      end
    end
  end
end
