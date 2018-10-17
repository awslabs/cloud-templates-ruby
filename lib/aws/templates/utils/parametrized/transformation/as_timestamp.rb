require 'aws/templates/utils'
require 'time'

module Aws
  module Templates
    module Utils
      module Parametrized
        class Transformation
          ##
          # Convert value into Time object
          #
          # Input value can be anything implementing :to_s method.
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #
          #      parameter :param, :transform => as_timestamp
          #    end
          #
          #    i = Piece.new
          #    i.param # => nil
          #    i = Piece.new(:param => '01 May 2018 10:00:00')
          #    i.param # => <Time>
          class AsTimestamp < self
            def compatible_with?(other)
              other.is_a?(self.class)
            end

            protected

            def transform(value, _)
              return if value.nil?
              return value if value.is_a?(Time)

              Time.parse(value.to_s)
            end
          end
        end
      end
    end
  end
end
