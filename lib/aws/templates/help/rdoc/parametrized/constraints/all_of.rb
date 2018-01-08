require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Parametrized
          module Constraints
            ##
            # Chained constraint provider
            #
            # Prints documentation blocks for all of the nexted constraints in the chain.
            class AllOf < Parametrized::Constraint
              for_entity Templates::Utils::Parametrized::Constraint::AllOf

              protected

              def add_description(item)
                item << text('satisfies all of the following:')
                item << members
              end

              private

              def members
                list(:BULLET) do |l|
                  context.constraints
                         .lazy
                         .map { |constraint| processed_for(constraint) }
                         .each { |part| l << part }
                end
              end
            end
          end
        end
      end
    end
  end
end
