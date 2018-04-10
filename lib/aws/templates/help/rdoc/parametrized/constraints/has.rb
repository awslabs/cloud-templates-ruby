require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Parametrized
          module Constraints
            ##
            # Has constraint documentation provider
            #
            # Prints defined fields and constraints for them.
            class Has < Schemed
              for_entity Templates::Utils::Parametrized::Constraint::Has

              protected

              def header
                'should have the fields:'
              end
            end
          end
        end
      end
    end
  end
end
