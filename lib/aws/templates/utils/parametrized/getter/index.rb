require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Parametrized
        class Getter
          ##
          # Lookup value in options by index
          #
          # Looks up value from options attribute by specified index.
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #
          #      parameter :param1, getter: index(:a)
          #    end
          #
          #    i = Piece.new(a: 3)
          #    i.param1 # => 3
          class Index < self
            attr_reader :index

            def initialize(index)
              @index = index
            end

            def arguments
              [index]
            end

            protected

            def get(_, instance)
              instance.options[index]
            end
          end
        end
      end
    end
  end
end
