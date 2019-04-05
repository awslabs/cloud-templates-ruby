require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Expressions
        ##
        # Basic function class
        #
        # It's the parent for both Operations and Functions containing common functionality such
        # as arguments extraction (getter) and equality condition.
        class BasicFunction
          ##
          # Transform to boxed
          #
          # Transforms values into their respective boxed representation in the framework.
          class AsBoxedExpression < Utils::Parametrized::Transformation
            extend Utils::Singleton

            protected

            def transform(value, instance)
              instance.scope.cast_for(value)
            end
          end

          include Utils::Parametrized
          include Expressions::Expression
          include Utils::Equalizable

          attr_reader :arguments

          def self.as_boxed_expression
            AsBoxedExpression.new
          end

          def self.getter
            proc { |p| arguments[self.class.arguments_list[p.name]] }
          end

          def self.arguments_list
            @arguments_list ||= Hash[parameters.keys.each_with_index.to_a]
          end

          def self.arity
            arguments_list.size
          end

          def equal_to?(other)
            parameters_map.eql?(other.parameters_map)
          end

          def dependency?
            true
          end

          def links
            dependencies
          end

          def initialize(scope, *args)
            super(scope)
            _check_arguments_number(args)
            @arguments = args
            validate
          end

          private

          def _check_arguments_number(args)
            expected = self.class.arity
            given = args.size

            return if expected == given

            raise ArgumentError.new(
              "wrong number of arguments (given #{given}, expected #{expected})"
            )
          end
        end
      end
    end
  end
end
