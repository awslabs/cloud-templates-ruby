require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module LateBound
        module Values
          class Value < BasicValue
            using Utils::Parametrized::Constraint::Refinements

            attr_reader :constraint

            def self.for(link, _instance, _transform, constraint)
              new(link, constraint)
            end

            def initialize(link, constraint)
              super(link)
              @constraint = constraint
            end

            def check_constraint(other_constraint, instance)
              return if constraint.satisfies?(other_constraint)

              raise Templates::Exception::ParameterLateBoundException.new(
                other_constraint,
                instance,
                self,
                "Late bound with constraint #{constraint} doesn't satisfy the target"
              )
            end

            def transform_as(transform, instance)
              return self if transform.nil?

              raise Templates::Exception::ParameterLateBoundException.new(
                transform,
                instance,
                self,
                'Untyped late bound value can\'t be transformed'
              )
            end
          end
        end
      end
    end
  end
end
