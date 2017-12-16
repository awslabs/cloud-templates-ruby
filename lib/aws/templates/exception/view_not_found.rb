require 'aws/templates/utils'

module Aws
  module Templates
    module Exception
      ##
      # View was not found for the object
      #
      # View map was checked and there is no appropriate view class
      # for the object class found in the registry.
      class ViewNotFound < RuntimeError
        # Instance of the object class render lookup was performed for
        attr_reader :instance

        def message
          "Can't find any view for #{instance.inspect} of class #{instance.class}"
        end

        def initialize(target_instance)
          super()
          @instance = target_instance
        end
      end
    end
  end
end
