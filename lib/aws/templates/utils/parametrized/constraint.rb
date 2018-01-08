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
          ##
          # Creates closure with checker invocation
          #
          # It's an interface method required for Constraint to expose
          # functor properties. It encloses invocation of Constraint check_wrapper
          # method into a closure. The closure itself is executed in the context
          # of Parametrized instance which provides proper set "self" variable.
          #
          # The closure itself accepts 2 parameters:
          # * +parameter+ - the Parameter object which the constraint is evaluated
          #                 against
          # * +value+ - parameter value to be checked
          # ...where instance is assumed from self
          def to_proc
            constraint = self

            lambda do |parameter, value|
              constraint.check_wrapper(parameter, value, self)
            end
          end

          ##
          # Wraps constraint-dependent method
          #
          # It wraps constraint-dependent "check" method into a rescue block
          # to standardize exception type and information provided by failed
          # constraint validation
          # * +parameter+ - the Parameter object which the constraint is evaluated
          #                 against
          # * +value+ - parameter value to be checked
          # * +instance+ - the instance value is checked for
          def check_wrapper(parameter, value, instance)
            check(parameter, value, instance) if pre_condition.check(value, instance)
          rescue StandardError
            raise Templates::Exception::ParameterValueInvalid.new(parameter, instance, value)
          end

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

          protected

          ##
          # Constraint-dependent check
          #
          # * +parameter+ - the Parameter object which the constraint is evaluated
          #                 against
          # * +value+ - parameter value to be checked
          # * +instance+ - the instance value is checked for
          def check(parameter, value, instance); end
        end
      end
    end
  end
end
