require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Parametrized
          module Constraints
            ##
            # Module constraint documentation provider
            class IsModule < Parametrized::Constraint
              for_entity Templates::Utils::Parametrized::Constraint::IsModule

              ##
              # Just prints the blurb
              class Baseless < self
                for_entity Templates::Utils::Parametrized::Constraint::IsModule::Baseless
              end

              ##
              # Prints a blurb with base Module designation
              class Based < self
                for_entity Templates::Utils::Parametrized::Constraint::IsModule::Based

                protected

                def add_description(item)
                  item << text("should be #{context.base}")
                end
              end

              protected

              def add_description(item)
                item << text('should be a module')
              end
            end
          end
        end
      end
    end
  end
end
