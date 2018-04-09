require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Parametrized
        class Getter
          ##
          # Pick one of non-nil values returned by nested getters
          #
          # In general it plays the same role as || operator in Ruby. It
          # just picks first non-nil value returned by a list of getters
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #
          #      parameter :param1, :getter => one_of(
          #        path(:a, :b),
          #        path(:b, :c)
          #      )
          #    end
          #
          #    i = Piece.new( :a => { :b => 3 } )
          #    i.param1 # => 3
          #    i = Piece.new( :b => { :c => 4 } )
          #    i.param1 # => 4
          class OneOf < self
            attr_reader :getters

            def initialize(getters)
              @getters = getters
            end

            def get(parameter, instance)
              getters.lazy
                     .map { |g| instance.instance_exec(parameter, &g) }
                     .find { |v| !v.nil? }
            end
          end
        end
      end
    end
  end
end
