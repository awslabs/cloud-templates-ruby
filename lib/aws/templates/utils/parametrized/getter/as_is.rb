require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Parametrized
        class Getter
          ##
          # Get options value "as is"
          #
          # Gets value from options attribute by parameter's name without
          # any other operations performed.
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #
          #      parameter :param1, :getter => as_is
          #    end
          #
          #    i = Piece.new(:param1 => 3)
          #    i.param1 # => 3
          class AsIs < self
            protected

            def get(parameter, instance)
              instance.options[parameter.name]
            end
          end
        end
      end
    end
  end
end
