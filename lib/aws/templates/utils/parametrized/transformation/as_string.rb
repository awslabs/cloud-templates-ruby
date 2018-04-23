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
            extend Utils::Singleton
            using Utils::Dependency::Refinements

            protected

            def transform(value, _)
              return if value.nil?
              result = String(value)
              value.dependency? ? result.as_a_dependency.to(value) : result
            end
          end
        end
      end
    end
  end
end
