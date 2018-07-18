require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Parametrized
          module Transformations
            ##
            # Module transformation documentation
            #
            # Just prints documentation blurb since the transformation is not parametrizable.
            class AsModule < Rdoc::Parametrized::Transformation
              for_entity Templates::Utils::Parametrized::Transformation::AsModule

              def to_processed
                sub(text('lookup as a module'))
              end
            end
          end
        end
      end
    end
  end
end
