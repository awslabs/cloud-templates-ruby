require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Parametrized
          module Constraints
            ##
            # Is constraint documentation provider
            #
            # Prints defined class and fields constraints.
            class Is < Schemed
              for_entity Templates::Utils::Parametrized::Constraint::Is

              protected

              def header
                'should be an instance of:'
              end
            end
          end
        end
      end
    end
  end
end
