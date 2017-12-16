require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Parametrized
        class Transformation
          ##
          # Convert input into integer
          #
          # Input value can be anything implementing :to_i method.
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #
          #      parameter :param, :transform => as_integer
          #    end
          #
          #    i = Piece.new
          #    i.param # => nil
          #    i = Piece.new(:param => '23')
          #    i.param # => 23
          class AsInteger < self
            include ::Singleton

            protected

            def transform(_, value, _)
              return if value.nil?
              Integer(value)
            end
          end
        end
      end
    end
  end
end
