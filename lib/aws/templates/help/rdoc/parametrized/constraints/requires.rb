require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Parametrized
          module Constraints
            ##
            # Requires dependency provider
            #
            # Prints all requirements for the constraint.
            class Requires < Parametrized::Constraint
              for_entity Templates::Utils::Parametrized::Constraint::Requires

              protected

              def add_description(item)
                item << text("requires the following parameters: #{requirements}")
              end

              private

              def requirements
                context.dependencies.map(&:to_s).join(',')
              end
            end
          end
        end
      end
    end
  end
end
