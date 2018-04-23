require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Parametrized
        ##
        # Getter functor class
        #
        # A getter is a Proc without parameters and it is expected to return
        # a value. Since the proc is to be executed in instance context
        # the value can be calculated based on other methods or extracted from
        # options attrribute
        #
        # The class implements functor pattern through to_proc method and
        # closure. Essentially, all getters can be used everywhere where
        # a block is expected.
        #
        # It provides protected method get which should be overriden in
        # all concrete getter classes.
        class Getter
          include Utils::Dsl::Element

          ##
          # Creates closure with getter invocation
          #
          # It's an interface method required for Getter to expose
          # functor properties. It encloses invocation of Getter get_wrapper
          # method into a closure. The closure itself is executed in the context
          # of Parametrized instance which provides proper set "self" variable.
          #
          # The closure itself accepts 1 parameters
          # * +parameter+ - the Parameter object which the getter is executed for
          # ...where instance is assumed from self
          def to_proc
            getter = self

            lambda do |parameter|
              getter.get_wrapper(parameter, self)
            end
          end

          ##
          # Wraps getter-dependent method
          #
          # It wraps constraint-dependent "get" method into a rescue block
          # to standardize exception type and information provided by failed
          # value calculation
          # * +parameter+ - the Parameter object which the getter is executed for
          # * +instance+ - the instance value is taken from
          def get_wrapper(parameter, instance)
            get(parameter, instance)
          rescue StandardError
            raise Templates::Exception::ParameterGetterException.new(self)
          end

          protected

          ##
          # Getter method
          #
          # * +parameter+ - the Parameter object which the getter is executed for
          # * +instance+ - the instance value is taken from
          def get(parameter, instance); end
        end
      end
    end
  end
end
