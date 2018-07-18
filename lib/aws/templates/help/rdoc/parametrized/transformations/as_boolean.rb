require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Parametrized
          module Transformations
            ##
            # Boolean transformation documentation
            #
            # Just prints the documentation blurb.
            class AsBoolean < Rdoc::Parametrized::Transformation
              for_entity Templates::Utils::Parametrized::Transformation::AsBoolean

              def to_processed
                sub(text('to boolean'))
              end
            end
          end
        end
      end
    end
  end
end
