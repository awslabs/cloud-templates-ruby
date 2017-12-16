require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Parametrized
        class Getter
          ##
          # Calculate value
          #
          # If a block is specified, it will be executed in the instance
          # context and return will be used as parameter value. If a value
          # specified then it will be used as parameter value instead.
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #
          #      parameter :param1, :getter => value(1)
          #      parameter :param2, :getter => value { options[:z] + 1 }
          #    end
          #
          #    i = Piece.new(:z => 3)
          #    i.param2 # => 4
          #    i.param1 # => 1
          class Value < self
            attr_reader :calculation

            def initialize(calculation)
              @calculation = calculation
            end

            protected

            def get(_, instance)
              if calculation.respond_to?(:to_hash)
                calculation
              elsif calculation.respond_to?(:to_proc)
                instance.instance_eval(&calculation)
              else
                calculation
              end
            end
          end
        end
      end
    end
  end
end
