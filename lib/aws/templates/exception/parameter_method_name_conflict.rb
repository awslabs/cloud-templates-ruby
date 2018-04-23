require 'aws/templates/utils'

module Aws
  module Templates
    module Exception
      ##
      # A regular method and a parameter have the same name in a class
      #
      # A parameter was specified with the same name as exsiting method
      # in the class or in an ancestor of the class.
      class ParameterMethodNameConflict < ParametrizedDslError
        # Method object of the method specified
        attr_reader :method_object

        def initialize(target_method)
          @method_object = target_method

          super(
            "Parameter name #{target_method.name} clashes with a method name in " \
            "#{target_method.owner.name}"
          )
        end
      end
    end
  end
end
