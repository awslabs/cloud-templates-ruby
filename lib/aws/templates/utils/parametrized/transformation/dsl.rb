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
            include Utils::Inheritable

            class_scope do
              ##
              # Chain a few transformations into a single one
              #
              # alias for AsChain class
              def as_chain(*components)
                Parametrized::Transformation::AsChain.new(components)
              end

              ##
              # Transform the value into an object
              #
              # alias for AsObject class
              def as_object(klass = nil, &definition)
                Parametrized::Transformation::AsObject.new(self, klass, &definition)
              end

              ##
              # Transform the value into a list
              #
              # alias for AsList class
              def as_list(parameters = nil)
                Parametrized::Transformation::AsList.new(self, parameters)
              end

              ##
              # Transform value with the specified render
              #
              # alias for AsRendered class
              def as_rendered(render_type, params = nil, &params_block)
                Parametrized::Transformation::AsRendered.new(render_type, params || params_block)
              end

              ##
              # Parse the value
              #
              # alias for AsParsed class
              def as_parsed(parser, params = nil, &params_block)
                Parametrized::Transformation::AsParsed.new(parser, params || params_block)
              end

              ##
              # Convert input into integer
              #
              # alias for AsInteger class
              def as_integer
                Parametrized::Transformation::AsInteger.instance
              end

              ##
              # Convert input into float
              #
              # alias for AsFloat class
              def as_float
                Parametrized::Transformation::AsFloat.instance
              end

              ##
              # Convert input into string
              #
              # alias for AsString class
              def as_string
                Parametrized::Transformation::AsString.instance
              end

              ##
              # Convert input into boolean
              #
              # alias for AsBoolean class
              def as_boolean
                Parametrized::Transformation::AsBoolean.instance
              end

              ##
              # Convert input into hash
              #
              # alias for AsHash class
              def as_hash(&blk)
                Parametrized::Transformation::AsHash.new(self, &blk)
              end

              ##
              # Convert input into a class
              #
              # alias for AsModule class
              def as_module
                Parametrized::Transformation::AsModule.instance
              end
            end
          end
        end
      end
    end
  end
end
