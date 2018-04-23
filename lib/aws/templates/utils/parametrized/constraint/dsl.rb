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
            extend Utils::Dsl

            # Value shouldn't be nil
            elements Constraint::NotNil,
                     # Value should be in enumeration
                     Constraint::Enum,
                     # Value should satisfy all constraints
                     Constraint::AllOf,
                     # Requires presence of the parameters if condition is satisfied
                     Constraint::Requires,
                     # Constraint depends on value
                     Constraint::DependsOnValue,
                     # Constraint should satisfy the condition
                     Constraint::SatisfiesCondition,
                     # Value should match the regular experession
                     Constraint::Matches,
                     # Value should match the regular expression
                     Constraint::IsModule,
                     # Check object class and constraints if specified
                     Constraint::Is,
                     # Check if object has specified fields and value constraints if specified
                     Constraint::Has
          end
        end
      end
    end
  end
end
