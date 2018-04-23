require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Parametrized
        class Transformation
          ##
          # Convert input into boolean
          #
          # Input value can be anything implementing :to_s method. Value considered false if it is:
          # * +'false' as a string+
          # * +FalseClass+
          # Otherwise, value is true. If value is nil, it won't be replaced by "false"
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #
          #      parameter :param, :transform => as_boolean
          #    end
          #
          #    i = Piece.new
          #    i.param # => false
          #    i = Piece.new(:param => 0)
          #    i.param # => true
          class AsBoolean < self
            extend Utils::Singleton

            protected

            def transform(value, _)
              return if value.nil?
              !value.to_s.casecmp('false').zero?
            end
          end
        end
      end
    end
  end
end
