require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Parametrized
          module Transformations
            ##
            # Integer transformation documentation
            #
            # Just prints the blurb since the transformation is not parametrizable.
            class AsInteger < Rdoc::Parametrized::Transformation
              register_in Rdoc
              for_entity Templates::Utils::Parametrized::Transformation::AsInteger

              def provide
                sub(text('to integer'))
              end
            end
          end
        end
      end
    end
  end
end
