require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Parametrized
        class Constraint
          ##
          # Syntax sugar for constraints definition
          #
          # It injects the methods as class-scope methods into mixing classes.
          # The methods are factories to create particular type of constraint
          module Dsl
            include Utils::Inheritable

            class_scope do
              ##
              # Match-all precondition
              #
              # Any constraint with this precondition will process any value
              def any
                Constraint::Condition.any
              end

              ##
              # Parameter shouldn't be nil
              #
              # alias for NotNil class
              def not_nil
                Parametrized::Constraint::NotNil.new
              end

              ##
              # Parameter value should be in enumeration
              #
              # alias for Enum class
              def enum(*items)
                Parametrized::Constraint::Enum.new(items.flatten)
              end

              ##
              # Parameter value should satisfy all specified constraints
              #
              # alias for AllOf class
              def all_of(*constraints)
                Parametrized::Constraint::AllOf.new(constraints)
              end

              ##
              # Requires presence of the parameters if condition is satisfied
              #
              # alias for Requires class
              def requires(*dependencies)
                Parametrized::Constraint::Requires.new(dependencies)
              end

              ##
              # Constraint depends on value
              #
              # alias for DependsOnValue class
              def depends_on_value(selector)
                Parametrized::Constraint::DependsOnValue.new(selector)
              end

              ##
              # Constraint should satisfy the condition
              #
              # alias for SatisfiesCondition class
              def satisfies(description, &cond_block)
                Parametrized::Constraint::SatisfiesCondition.new(description, &cond_block)
              end

              ##
              # Value should match the regular experession
              #
              # alias for Matches
              def matches(rex)
                Parametrized::Constraint::Matches.new(rex)
              end
            end
          end
        end
      end
    end
  end
end
