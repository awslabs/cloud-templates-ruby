require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Parametrized
        class Transformation
          ##
          # Convert input into float
          #
          # Input value can be anything implementing :to_f method.
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #
          #      parameter :param, :transform => as_float
          #    end
          #
          #    i = Piece.new
          #    i.param # => nil
          #    i = Piece.new(:param => '23.0')
          #    i.param # => 23.0
          class AsFloat < self
            def compatible_with?(other)
              other.is_a?(self.class)
            end

            protected

            def transform(value, _)
              return if value.nil?
              Float(value)
            end
          end
        end
      end
    end
  end
end
