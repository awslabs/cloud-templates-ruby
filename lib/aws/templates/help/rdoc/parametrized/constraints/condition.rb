require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Parametrized
          module Constraints
            ##
            # Abstract condition documentation provider
            class Condition < Rdoc::Provider
              for_entity Templates::Utils::Parametrized::Constraint::Condition

              ##
              # Equality condition documentation provider
              #
              # Outputs text block with value description.
              class Equal < Condition
                for_entity Templates::Utils::Parametrized::Constraint::Condition::Equal

                def to_processed
                  value = context.expected
                  text("_when_ value #{value.nil? ? 'is nil' : "== #{value.inspect}"}")
                end
              end

              ##
              # Code-block condition documentation
              class Conditional < Condition
                for_entity Templates::Utils::Parametrized::Constraint::Condition::Conditional

                def to_processed
                  text("_when_ #{context.condition.source_location.join(':')}")
                end
              end

              def to_processed; end
            end
          end
        end
      end
    end
  end
end
