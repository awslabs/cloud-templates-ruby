require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Parametrized
          module Transformations
            ##
            # Timestamp transformation documentation
            #
            # Just prints the documentation blurb.
            class AsTimestamp < Rdoc::Parametrized::Transformation
              for_entity Templates::Utils::Parametrized::Transformation::AsTimestamp

              def provide
                sub(text('to timestamp'))
              end
            end
          end
        end
      end
    end
  end
end
