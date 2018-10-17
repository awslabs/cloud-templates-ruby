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
          class AsHash < self
            attr_reader :definition

            def initialize(&blk)
              @definition = Transformation::AsHashDefinition.new(&blk) if blk
            end

            def compatible_with?(other)
              return false unless other.is_a?(self.class)

              definition.nil? || definition.compatible_with?(other.definition)
            end

            protected

            def transform(value, instance)
              return if value.nil?

              result = Hash[value]

              result = _process_hash(definition, result, instance) unless definition.nil?

              result
            end

            private

            def _process_hash(definition, hsh, instance)
              Hash[
                hsh.map do |k, v|
                  [
                    _process_value(definition.key_parameter, instance, k),
                    _process_value(definition.value_parameter, instance, v)
                  ]
                end
              ]
            end

            def _process_value(parameter, instance, value)
              return value if parameter.nil?

              parameter.process_value(instance, value)
            end
          end
        end
      end
    end
  end
end
