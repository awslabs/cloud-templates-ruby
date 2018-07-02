require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Parametrized
        class Transformation
          ##
          # Syntax sugar for transformations definition
          #
          # It injects the methods as class-scope methods into mixing classes.
          # The methods are factories to create particular type of transformation
          module Dsl
            extend Utils::Dsl

            elements Transformation::AsChain, # Chain a few transformations into a single one
                     Transformation::AsObject, # Transform the value into an object
                     Transformation::AsList, # Transform the value into a list
                     Transformation::AsRendered, # Transform value with the specified render
                     Transformation::AsParsed, # Parse the value
                     Transformation::AsInteger, # Convert input into integer
                     Transformation::AsFloat, # Convert input into float
                     Transformation::AsString, # Convert input into string
                     Transformation::AsBoolean, # Convert input into boolean
                     Transformation::AsHash, # Convert input into hash
                     Transformation::AsModule, # Convert input into a class
                     Transformation::AsExpression, # Convert input into an "expression"
                     Transformation::AsJson, # Print the value into JSON string
                     Transformation::AsTimestamp # Transform passed value into Time object
          end
        end
      end
    end
  end
end
