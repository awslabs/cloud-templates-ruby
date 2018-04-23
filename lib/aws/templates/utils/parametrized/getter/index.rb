require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Parametrized
        class Getter
          ##
          # Lookup value in options by path
          #
          # Looks up value from options attribute by specified path. The path
          # can be either statically specified or a block can be provided.
          # The block shouldn't have parameters and should return an array
          # containing path. The block will be executed in the instance context.
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #
          #      parameter :param1, :getter => path(:a, :b)
          #    end
          #
          #    i = Piece.new(:a => { :b => 3 })
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
