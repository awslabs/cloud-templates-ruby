require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Parametrized
        class Transformation
          ##
          # Convert to a Ruby class
          #
          # The transformation allows to use elements of metaprogramming in the framework. It
          # tries to transform passed value to a Ruby class.
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #
          #      parameter :param, :transform => as_module
          #    end
          #
          #    i = Piece.new
          #    i.param # => nil
          #    i = Piece.new(:param => 'Object')
          #    i.param # => Object
          class AsModule < self
            include ::Singleton

            protected

            def transform(_, value, _)
              return if value.nil?
              return value if value.is_a?(Module)
              return Utils.lookup_module(value.to_s) if value.respond_to?(:to_s)
              raise "#{value} can't be transformed to a class"
            end
          end
        end
      end
    end
  end
end
