require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Parametrized
          module Constraints
            ##
            # Condition constraint
            #
            # Just prints condition description.
            class SatisfiesCondition < Parametrized::Constraint
              register_in Rdoc
              for_entity Templates::Utils::Parametrized::Constraint::SatisfiesCondition

              protected

              def add_description(item)
                item << text(context.description)
              end
            end
          end
        end
      end
    end
  end
end
