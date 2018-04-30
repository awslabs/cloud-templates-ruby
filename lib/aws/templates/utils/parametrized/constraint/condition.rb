require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Parametrized
        class Constraint
          ##
          # Condition
          #
          # Condition is a strategy which decides if some particular constraint should be enforced
          # or not.
          class Condition
            ##
            # Enforce constraint in all cases
            class Unconditional < Condition
              def check(_, _)
                true
              end
            end

            ##
            # Do not evaluate constraint if value is nil
            class NotNil < Condition
              def check(value, _)
                !value.nil?
              end
            end

            ##
            # If value is equal to the condition then evaluate constraint
            class Equal < Condition
              attr_reader :expected

              def initialize(expected)
                @expected = expected
              end

              def check(value, _)
                value == expected
              end
            end

            ##
            # Check specified lambda if constraint should be evaluated
            class Conditional < Condition
              attr_reader :condition

              def initialize(condition)
                @condition = condition
              end

              def check(value, instance)
                instance.instance_exec(value, &condition)
              end
            end

            def check(_value, _instance)
              raise 'Must be overriden'
            end

            ##
            # Factory method for Unconditional singleton
            def self.any
              @any ||= Unconditional.new
            end

            ##
            # Factory method for NotNil singleton
            def self.not_nil
              @not_nil ||= NotNil.new
            end

            ##
            # Factory method transforming arbitrary object into Condition object depending
            # on object's concept.
            def self.for(condition)
              if condition.is_a?(self)
                condition
              elsif condition.respond_to?(:to_sym)
                Equal.new(condition)
              elsif condition.respond_to?(:to_proc)
                Conditional.new(condition)
              else
                Equal.new(condition)
              end
            end
          end
        end
      end
    end
  end
end
