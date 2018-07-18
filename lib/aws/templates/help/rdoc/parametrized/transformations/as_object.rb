require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Parametrized
          module Transformations
            ##
            # Object transformation documentation
            #
            # Prints documentation for the transformation of a parameter where nested structure is
            # defined. Nested class description is provided.
            class AsObject < Rdoc::Parametrized::Transformation
              for_entity Templates::Utils::Parametrized::Transformation::AsObject

              def to_processed
                klass = processed_for(context.klass)

                if klass.nil?
                  sub(text('as an object'))
                else
                  sub(text('as an object with:'), processed_for(context.klass))
                end
              end
            end
          end
        end
      end
    end
  end
end
