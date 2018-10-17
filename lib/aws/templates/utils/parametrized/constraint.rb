require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Parametrized
        ##
        # Constraint functor class
        #
        # A constraint is a Proc which accepts one parameter which is a value
        # which needs to be checked and ir is expected to throw an exception
        # if the value is not in compliance with the constraint
        #
        # The class implements functor pattern through to_proc method and
        # closure. Essentially, all constraints can be used everywhere where
        # a block is expected.
        #
        # It provides protected method check which should be overriden in
        # all concrete constraint classes.
        class Constraint
          include Utils::Dsl::Element
          include Utils::Functor

          # TODO: eyebleed. Callback hell's gates

          ##
          # Constraint adaptors
          #
          # Default method implementations for
          # * BasicObject - adds default check_constraint hook implementation which just checks
          #                 the values against the passed constraint
          # * Proc, NilClass - makes the types compatible with test methods of constraint class
          module Refinements
            refine ::BasicObject do
              def check_constraint(constraint, instance)
                return if constraint.nil?

                constraint.check_wrapper(self, instance)
              end
            end

            refine ::Proc do
              def satisfied_by?(other)
                eql?(other)
              end

              def satisfies?(other)
                other.nil? || other.satisfied_by?(self)
              end
            end

            refine ::NilClass do
              def satisfied_by?(_other)
                true
              end

              def satisfies?(other)
                other.nil? || other.satisfied_by?(self)
              end
            end
          end

          using Refinements

          ##
          # Change precondition of the constraint
          #
          # Pre-condition is a modifier to the main constraint. The constraint won't be evaluated
          # if pre-condition is not met. Default condition is that value should be not nil meaning
          # that if the value is nil then the constraint will be ignored.
          def if(*params, &blk)
            @pre_condition = Condition.for(
              if params.empty?
                raise 'Block must be specified' unless block_given?

                blk
              else
                params.first
              end
            )

            self
          end

          def pre_condition
            @pre_condition ||= Condition.not_nil
          end

          def transform_as(_transform, _instance)
            nil
          end

          def invoke(instance, value)
            value.check_constraint(self, instance)
          end

          def satisfied_by?(other)
            eql?(other)
          end

          def satisfies?(other)
            other.nil? || other.satisfied_by?(self)
          end

          ##
          # Wraps constraint-dependent method
          #
          # It wraps constraint-dependent "check" method into a rescue block
          # to standardize exception type and information provided by failed
          # constraint validation
          # * +value+ - parameter value to be checked
          # * +instance+ - the instance value is checked for
          def check_wrapper(value, instance)
            check(value, instance) if pre_condition.check(value, instance)
          rescue StandardError
            raise Templates::Exception::ParameterConstraintException.new(self, instance, value)
          end

          protected

          ##
          # Constraint-dependent check
          #
          # * +value+ - parameter value to be checked
          # * +instance+ - the instance value is checked for
          def check(value, instance); end
        end
      end
    end
  end
end
