require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Parametrized
          module Constraints
            ##
            # Case-like constraint documentation provider
            #
            # Prints all handled value and respective constraints.
            class DependsOnValue < Schemed
              for_entity Templates::Utils::Parametrized::Constraint::DependsOnValue

              protected

              def header
                'depends on value:'
              end
            end
          end
        end
      end
    end
  end
end
