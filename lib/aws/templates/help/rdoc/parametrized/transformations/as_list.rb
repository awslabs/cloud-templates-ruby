require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Parametrized
          module Transformations
            ##
            # List transformation documentation
            #
            # Outputs documentation for sub-parameter (element).
            class AsList < Rdoc::Parametrized::Transformation
              for_entity Templates::Utils::Parametrized::Transformation::AsList

              def provide
                parameter = context.sub_parameter
                sub do |s|
                  if parameter.nil?
                    s << text('as a list where elements can be anything')
                  else
                    s << text('as a list where elements are:') << processed_for(parameter)
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
