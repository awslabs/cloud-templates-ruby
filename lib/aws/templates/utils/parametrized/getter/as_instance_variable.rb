require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Parametrized
        class Getter
          ##
          # Get parameter from instance variables as is
          #
          # Gets value from instance variable by parameter's name without
          # any other operations performed.
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #
          #      parameter :param1, getter: as_instance_variable
          #
          #      def initialize(x)
          #        @param1 = x
          #      end
          #    end
          #
          #    i = Piece.new(3)
          #    i.param1 # => 3
          class AsInstanceVariable < self
            protected

            def get(parameter, instance)
              instance.instance_variable_get("@#{parameter.name}")
            end
          end
        end
      end
    end
  end
end
