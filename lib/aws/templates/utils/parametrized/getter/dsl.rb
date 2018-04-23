require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Parametrized
        class Getter
          ##
          # Syntax sugar for getters definition
          #
          # It injects the methods as class-scope methods into mixing classes.
          # The methods are factories to create particular type of getter
          module Dsl
            extend Utils::Dsl

            elements Getter::AsInstanceVariable, # Get parameter from instance variables as is
                     Getter::AsIs, # Get parameter from Options as is
                     Getter::Value, # Calculate value of parameter
                     Getter::Path, # Look up value of the parameter with path
                     Getter::OneOf, # Choose one non-nil value from nested getters
                     Getter::Index # Look up value of the parameter with index
          end
        end
      end
    end
  end
end
