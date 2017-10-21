require 'aws/templates/exceptions'
require 'aws/templates/utils/parametrized'
require 'set'

module Aws
  module Templates
    module Utils
      module Parametrized #:nodoc:
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
          # Check if passed value is not nil
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #
          #      parameter :param1, :constraint => not_nil
          #    end
          #
          #    i = Piece.new(:param1 => 3)
          #    i.param1 # => 3
          #    i = Piece.new
          #    i.param1 # throws ParameterValueInvalid
          class NotNil < Constraint
            def initialize
              self.if(nil)
            end

            protected

            def check(_, value, _)
              raise('required but was not found in input hash') if value.nil?
            end
          end

          ##
          # Check if passed value is in the enumeration values.
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #
          #      parameter :param1, :constraint => enum([1,'2',3])
          #    end
          #
          #    i = Piece.new(:param1 => 3)
          #    i.param1 # => 3
          #    i = Piece.new(:param1 => 4)
          #    i.param1 # throws ParameterValueInvalid
          class Enum < Constraint
            attr_reader :set

            def initialize(list)
              @set = Set.new(list)
            end

            protected

            def check(_, value, _)
              return if set.include?(value)

              raise(
                "Value #{value.inspect} is not in the set of allowed " \
                "values #{set.inspect}"
              )
            end
          end

          ##
          # Switch-like variant check
          #
          # Recursive check implementing switch-based semantics for defining
          # checks need to be performed depending on parameter's value.
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #      parameter :param2
          #      parameter :param1,
          #        :constraint => depends_on_value(
          #          1 => lambda { |v| raise 'Too big' if param2 > 3 },
          #          2 => lambda { |v| raise 'Too small' if param2 < 2 }
          #        )
          #    end
          #
          #    i = Piece.new(:param1 => 1, :param2 => 1)
          #    i.param1 # => 1
          #    i = Piece.new(:param1 => 1, :param2 => 5)
          #    i.param1 # raise ParameterValueInvalid
          #    i = Piece.new(:param1 => 2, :param2 => 1)
          #    i.param1 # raise ParameterValueInvalid
          #    i = Piece.new(:param1 => 2, :param2 => 5)
          #    i.param1 # => 2
          class DependsOnValue < Constraint
            ##
            # Selector hash
            attr_reader :selector

            def initialize(selector)
              @selector = selector
              self.if(Parametrized.any)
            end

            protected

            def check(parameter, value, instance)
              return unless selector.key?(value)

              instance.instance_exec(
                parameter,
                value,
                &selector[value]
              )
            end
          end

          ##
          # Check presence of parameters if the condition is met
          #
          # Requires presence of the methods passed as dependencies in the
          # current scope with non-nil returning values. Default condition
          # for the value is not to be nil. The condition can be either
          # a block or a value.
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #      parameter :param2
          #      parameter :param1, :constraint => requires(:param2)
          #    end
          #
          #    i = Piece.new(:param2 => 1)
          #    i.param1 # => nil
          #    i = Piece.new(:param1 => 1)
          #    i.param1 # raise ParameterValueInvalid
          #    i = Piece.new(:param1 => 2, :param2 => 1)
          #    i.param1 # => 2
          class Requires < Constraint
            attr_reader :dependencies
            attr_reader :condition

            def initialize(dependencies)
              @dependencies = dependencies
            end

            protected

            def check(parameter, value, instance)
              dependencies.each do |pname|
                next unless instance.send(pname).nil?

                raise(
                  "#{pname} is required when #{parameter.name} value " \
                  "is set to #{value.inspect}"
                )
              end
            end
          end

          ##
          # Check if value satisfies the condition
          #
          # Checks if value satisfies the condition defined in the block
          # which should return true if the condition is met and false if it's
          # not. If value fails the check, an exception will be thrown
          # with attached condition description. The description is a part
          # of constraint definition.
          #
          # The block is evaluated in the functor's invocation context.
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #      parameter :param1,
          #        :constraint => satisfies('Mediocre value') { |v| v < 100 }
          #    end
          #
          #    i = Piece.new(:param2 => 1)
          #    i.param1 # => 1
          #    i = Piece.new(:param1 => 101)
          #    i.param1 # raise ParameterValueInvalid
          class SatisfiesCondition < Constraint
            attr_reader :condition
            attr_reader :description

            def initialize(description, &cond_block)
              @condition = cond_block
              @description = description
            end

            protected

            def check(parameter, value, instance)
              return if instance.instance_exec(value, &condition)

              raise(
                "#{value.inspect} doesn't satisfy the condition " \
                "#{description} for parameter #{parameter.name}"
              )
            end
          end

          ##
          # Check if value matches the regular expression
          #
          # Checks if value matches the regular expression. If value doesn't match, an exception
          # will be thrown with attached description of regular expression and value converted to
          # string.
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #      parameter :param1, constraint: matches('A+')
          #    end
          #
          #    i = Piece.new(:param1 => 'Ask')
          #    i.param1 # => 'Ask'
          #    i = Piece.new(:param1 => 'Bar')
          #    i.param1 # raise ParameterValueInvalid
          class Matches < Constraint
            attr_reader :expression

            def initialize(rex)
              @expression = Regexp.new(rex)
            end

            protected

            def check(parameter, value, _)
              return if expression =~ value.to_s
              raise "#{value} doesn't match #{expression} for parameter #{parameter.name}"
            end
          end

          ##
          # Aggregate constraint
          #
          # It is used to perform checks against a list of constraints-functors
          # or lambdas.
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #      parameter :param1,
          #        :constraint => all_of(
          #          not_nil,
          #          satisfies("Should be moderate") { |v| v < 100 }
          #        )
          #    end
          #
          #    i = Piece.new(:param1 => nil)
          #    i.param1 # raise ParameterValueInvalid
          #    i = Piece.new(:param1 => 200)
          #    i.param1 # raise ParameterValueInvalid with description
          #    i = Piece.new(:param1 => 50)
          #    i.param1 # => 50
          class AllOf < Constraint
            attr_reader :constraints

            def initialize(constraints)
              @constraints = constraints
              self.if(Parametrized.any)
            end

            protected

            def check(parameter, value, instance)
              constraints.each do |c|
                instance.instance_exec(parameter, value, &c)
              end
            end
          end

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
            check(parameter, value, instance) if pre_condition(value, instance)
          rescue StandardError
            raise ParameterValueInvalid.new(parameter, instance, value)
          end

          ##
          # Change precondition of the constraint
          #
          # Pre-condition is a modifier to the main constraint. The constraint won't be evaluated
          # if pre-condition is not met. Default condition is that value should be not nil meaning
          # that if the value is nil then the constraint will be ignored.
          def if(*params, &blk)
            @pre_condition = if params.empty?
              blk
            else
              test = params.first
              test.respond_to?(:to_proc) ? test : ->(v) { v == test }
            end

            self
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

          def pre_condition(value, instance)
            return !value.nil? if @pre_condition.nil?
            instance.instance_exec(value, &@pre_condition)
          end
        end

        ##
        # Syntax sugar for constraints definition
        #
        # It injects the methods as class-scope methods into mixing classes.
        # The methods are factories to create particular type of constraint
        class_scope do
          ##
          # Match-all precondition
          #
          # Any constraint with this precondition will process any value
          def any
            ->(_) { true }
          end

          ##
          # Parameter shouldn't be nil
          #
          # alias for NotNil class
          def not_nil
            Constraint::NotNil.new
          end

          ##
          # Parameter value should be in enumeration
          #
          # alias for Enum class
          def enum(*items)
            Constraint::Enum.new(items.flatten)
          end

          ##
          # Parameter value should satisfy all specified constraints
          #
          # alias for AllOf class
          def all_of(*constraints)
            Constraint::AllOf.new(constraints)
          end

          ##
          # Requires presence of the parameters if condition is satisfied
          #
          # alias for Requires class
          def requires(*dependencies)
            Constraint::Requires.new(dependencies)
          end

          ##
          # Constraint depends on value
          #
          # alias for DependsOnValue class
          def depends_on_value(selector)
            Constraint::DependsOnValue.new(selector)
          end

          ##
          # Constraint should satisfy the condition
          #
          # alias for SatisfiesCondition class
          def satisfies(description, &cond_block)
            Constraint::SatisfiesCondition.new(description, &cond_block)
          end

          ##
          # Value should match the regular experession
          #
          # alias for Matches
          def matches(rex)
            Constraint::Matches.new(rex)
          end
        end
      end
    end
  end
end
