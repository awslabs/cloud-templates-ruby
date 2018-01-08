require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Parametrized
          module Constraints
            ##
            # Regular expression constraint documentation provider
            #
            # Outputs regular expression.
            class Matches < Parametrized::Constraint
              for_entity Templates::Utils::Parametrized::Constraint::Matches

              protected

              def add_description(item)
                item << text("matches regular expression #{context.expression.inspect}")
              end
            end
          end
        end
      end
    end
  end
end
