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
            include Utils::Inheritable

            class_scope do
              ##
              # Get parameter from instance variables as is
              #
              # alias for AsInstanceVariable class
              def as_instance_variable
                Parametrized::Getter::AsInstanceVariable.instance
              end

              ##
              # Get parameter from Options as is
              #
              # alias for AsIs class
              def as_is
                Parametrized::Getter::AsIs.instance
              end

              ##
              # Calculate value of parameter
              #
              # alias for Value class
              def value(v = nil, &blk)
                Parametrized::Getter::Value.new(v.nil? ? blk : v)
              end

              ##
              # Look up value of the parameter with path
              #
              # alias for Path class
              def path(*v, &blk)
                Parametrized::Getter::Path.new(v.empty? ? blk : v)
              end

              ##
              # Choose one non-nil value from nested getters
              #
              # alias for OneOf class
              def one_of(*getters)
                Parametrized::Getter::OneOf.new(getters)
              end
            end
          end
        end
      end
    end
  end
end
