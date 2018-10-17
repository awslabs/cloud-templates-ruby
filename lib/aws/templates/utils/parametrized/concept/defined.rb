require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Parametrized
        class Concept
          ##
          # Defined concept
          #
          # "Defined" concept has constraint or transformation or both defined and processes
          # the target value through the transformation first and then check the resulkt against
          # the constraint.
          class Defined < self
            def self.as(transform: nil, constraint: nil)
              return Concept::Empty.new if transform.nil? && constraint.nil?

              new(transform: transform, constraint: constraint)
            end

            attr_reader :transform
            attr_reader :constraint

            def initialize(transform: nil, constraint: nil)
              @transform = _check_transform(transform)
              @constraint = _check_constraint(constraint)
            end

            def process_value(instance, value)
              _check_value(instance, _transform_value(instance, value))
            end

            private

            def _check_transform(transform)
              return transform if transform.nil? || transform.respond_to?(:to_proc)

              raise "#{transform.inspect} can't be used as transformation"
            end

            def _check_constraint(constraint)
              return constraint if constraint.nil? || constraint.respond_to?(:to_proc)

              raise "#{constraint.inspect} can't be used as constraint"
            end

            def _transform_value(instance, value)
              return value if transform.nil?

              instance.instance_exec(value, &transform)
            end

            def _check_value(instance, value)
              instance.instance_exec(value, &constraint) if constraint
              value
            end
          end
        end
      end
    end
  end
end
