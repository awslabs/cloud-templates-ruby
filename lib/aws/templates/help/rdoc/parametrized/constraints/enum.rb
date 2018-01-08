require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Parametrized
          module Constraints
            ##
            # Enumerable constraint documentation provider
            #
            # Outputs a list of all possible values for the parameter.
            class Enum < Parametrized::Constraint
              for_entity Templates::Utils::Parametrized::Constraint::Enum

              protected

              def add_description(item)
                item << text("one of: #{enumerate}")
              end

              private

              def enumerate
                context.set.map(&:inspect).join(',')
              end
            end
          end
        end
      end
    end
  end
end
