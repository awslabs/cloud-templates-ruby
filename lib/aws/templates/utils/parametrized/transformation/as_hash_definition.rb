require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Parametrized
        class Transformation
          ##
          # Convert input into hash
          #
          # Input value can be anything implementing :to_hash method.
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #
          #      parameter :param, :transform => as_hash
          #      parameter :param2,
          #        transform: as_hash {
          #          value name: :number,
          #            description: 'Number',
          #            constraint: not_nil,
          #            transform: as_integer
          #        }
          #    end
          #
          #    i = Piece.new
          #    i.param # => nil
          #    i = Piece.new(:param => [[1,2]])
          #    i.param # => {1=>2}
          #    i = Piece.new(:param2 => [[1,'3']])
          #    i.param # => {1=>3}
          class AsHashDefinition
            include Parametrized::Constraint::Dsl
            include Parametrized::Transformation::Dsl

            attr_reader :key_parameter
            attr_reader :value_parameter

            def key(opts)
              @key_parameter = _create_parameter(opts)
            end

            def value(opts)
              @value_parameter = _create_parameter(opts)
            end

            def initialize(&blk)
              instance_eval(&blk)
            end

            private

            def _create_parameter(opts)
              Parametrized::Parameter.new(
                opts[:name],
                description: opts[:description],
                transform: opts[:transform],
                constraint: opts[:constraint]
              )
            end
          end
        end
      end
    end
  end
end
