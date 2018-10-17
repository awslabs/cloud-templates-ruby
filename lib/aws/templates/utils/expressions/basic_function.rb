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
            using Utils::Expressions::Refinements
            extend Utils::Singleton

            protected

            def transform(value, _)
              raise "#{value.inspect} is not an expression" unless value.boxable_expression?

              value.to_boxed_expression
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
            @arguments_list ||= Hash[list_all_parameter_names.each_with_index.to_a]
          end

          def equal_to?(other)
            parameters_map == other.parameters_map
          end

          def initialize(*args)
            @arguments = args
            validate
          end
        end
      end
    end
  end
end
