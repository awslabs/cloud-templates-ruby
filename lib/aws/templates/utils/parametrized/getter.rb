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
          include Utils::Functor

          def invoke(instance, parameter)
            get_wrapper(parameter, instance)
          end

          protected

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
