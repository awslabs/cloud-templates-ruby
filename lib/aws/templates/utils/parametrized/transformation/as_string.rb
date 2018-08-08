require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Parametrized
        class Transformation
          ##
          # Convert input into string
          #
          # Input value can be anything implementing :to_s method.
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #
          #      parameter :param, :transform => as_string
          #    end
          #
          #    i = Piece.new
          #    i.param # => nil
          #    i = Piece.new(:param => 23)
          #    i.param # => '23'
          class AsString < self
            protected

            def transform(value, _)
              return if value.nil?
              String(value)
            end
          end
        end
      end
    end
  end
end
