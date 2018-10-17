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
            using Parametrized::Concept::Processable

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

            def compatible_with?(other)
              return false unless other.is_a?(self.class)

              (
                _compatible?(key_parameter, other.key_parameter) &&
                _compatible?(value_parameter, other.value_parameter)
              )
            end

            private

            def _create_key(name: nil, description: nil, transform: nil, constraint: nil)
              _create_parameter(name || :key, description, transform, constraint)
            end

            def _create_value(name: nil, description: nil, transform: nil, constraint: nil)
              _create_parameter(name || :value, description, transform, constraint)
            end

            def _create_parameter(name: nil, description: nil, transform: nil, constraint: nil)
              Parametrized::Parameter.new(
                name || :object,
                description: description,
                transform: transform,
                constraint: constraint
              )
            end

            def _compatible?(a_param, b_param)
              (b_param && b_param.concept).processable_by?(a_param && a_param.concept)
            end
          end
        end
      end
    end
  end
end
