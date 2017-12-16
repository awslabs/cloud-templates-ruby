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
            include Parametrized::ClassScope

            def key(opts)
              @key_parameter = _create_parameter(opts)
            end

            def value(opts)
              @value_parameter = _create_parameter(opts)
            end

            def initialize(klass = nil, &blk)
              @klass = klass
              instance_eval(&blk) if blk
            end

            protected

            def transform(_, value, instance)
              return if value.nil?

              Hash[
                Hash[value].map do |k, v|
                  [
                    _process_value(@key_parameter, instance, k),
                    _process_value(@value_parameter, instance, v)
                  ]
                end
              ]
            end

            def _process_value(parameter, instance, value)
              return value if parameter.nil?
              parameter.process_value(instance, value)
            end

            private

            def _create_parameter(opts)
              Parametrized::Parameter.new(
                opts[:name],
                @klass,
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
