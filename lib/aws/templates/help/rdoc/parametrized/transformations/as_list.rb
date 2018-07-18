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

              def to_processed
                parameter = context.sub_parameter
                sub do |s|
                  if parameter.nil?
                    s << text("#{_blurb} can be anything")
                  else
                    s << text("#{_blurb} are:") << processed_for(parameter)
                  end
                end
              end

              private

              def _blurb
                part = 'without duplicates ' if context.unique?
                "as a list #{part}where elements"
              end
            end
          end
        end
      end
    end
  end
end
