require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Parametrized
        class Constraint
          ##
          # Chained constraint common functionality
          #
          # Common functionality for chained constraints
          #
          class Chain < self
            using Parametrized::Transformation::Refinements
            using Constraint::Refinements

            attr_reader :constraints

            def initialize(*constraints)
              @constraints = if constraints.empty? && block_given?
                yield self
              else
                constraints
              end

              self.if(Constraint::Condition.any)
            end

            def transform_as(transform, instance)
              transformed =
                constraints
                .map { |constraint| instance.instance_exec(constraint, &transform) }
                .reject(&:nil?)

              return if transformed.empty?
              return transformed.first if transformed.size == 1

              self.class.new(*transformed)
            end
          end
        end
      end
    end
  end
end
