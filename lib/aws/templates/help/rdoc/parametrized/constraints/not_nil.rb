require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Parametrized
          module Constraints
            ##
            # Not-nil constraint documentation
            #
            # Just prints the blurb
            class NotNil < Parametrized::Constraint
              for_entity Templates::Utils::Parametrized::Constraint::NotNil

              protected

              def add_description(item)
                item << text('can\'t be nil')
              end
            end
          end
        end
      end
    end
  end
end
