require 'aws/templates/utils'
require 'json'

module Aws
  module Templates
    module Utils
      module Parametrized
        class Transformation
          ##
          # Convert input into JSON string
          #
          # Input value can be anything implementing :to_json method.
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #
          #      parameter :param, :transform => as_json
          #    end
          #
          #    i = Piece.new
          #    i.param # => nil
          #    i = Piece.new(:param => {q: 1})
          #    i.param # => '{"q":1}'
          class AsJson < self
            extend Utils::Singleton

            protected

            def transform(value, _)
              return if value.nil?
              value.to_json
            end
          end
        end
      end
    end
  end
end
