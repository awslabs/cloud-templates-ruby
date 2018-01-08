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
            class DependsOnValue < Parametrized::Constraint
              for_entity Templates::Utils::Parametrized::Constraint::DependsOnValue

              protected

              def add_description(item)
                item << text('depends on value:')
                item << _members
              end

              private

              def _members
                context.selector
                       .lazy
                       .map { |value, constraint| _constraint_variant_for(value, constraint) }
                       .each_with_object(list) { |part, l| l << part }
              end

              def _constraint_variant_for(value, constraint)
                sub(text("when _#{value}_ :"), processed_for(constraint))
              end
            end
          end
        end
      end
    end
  end
end
