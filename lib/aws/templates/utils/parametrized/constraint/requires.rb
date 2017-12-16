require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Parametrized
        class Constraint
          ##
          # Check presence of parameters if the condition is met
          #
          # Requires presence of the methods passed as dependencies in the
          # current scope with non-nil returning values. Default condition
          # for the value is not to be nil. The condition can be either
          # a block or a value.
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #      parameter :param2
          #      parameter :param1, :constraint => requires(:param2)
          #    end
          #
          #    i = Piece.new(:param2 => 1)
          #    i.param1 # => nil
          #    i = Piece.new(:param1 => 1)
          #    i.param1 # raise ParameterValueInvalid
          #    i = Piece.new(:param1 => 2, :param2 => 1)
          #    i.param1 # => 2
          class Requires < self
            attr_reader :dependencies
            attr_reader :condition

            def initialize(dependencies)
              @dependencies = dependencies
            end

            protected

            def check(parameter, value, instance)
              dependencies.each do |pname|
                next unless instance.send(pname).nil?

                raise(
                  "#{pname} is required when #{parameter.name} value " \
                  "is set to #{value.inspect}"
                )
              end
            end
          end
        end
      end
    end
  end
end
