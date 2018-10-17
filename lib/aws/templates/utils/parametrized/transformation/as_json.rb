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
            def compatible_with?(other)
              other.is_a?(self.class)
            end

            protected

            def transform(value, _)
              return if value.nil?
              return JSON.parse(value.to_str) if value.respond_to?(:to_str)
              raise "#{value} can't be transformed to JSON" unless value.respond_to?(:to_json)

              JSON.parse(value.to_json)
            end
          end
        end
      end
    end
  end
end
