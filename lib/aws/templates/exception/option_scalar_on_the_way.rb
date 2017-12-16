require 'aws/templates/utils'

module Aws
  module Templates
    module Exception
      ##
      # Scalar is met while traversing Options path
      #
      # Path is not empty yet but we can't traverse deeper because the current value is a scalar
      class OptionScalarOnTheWay < OptionError
        attr_reader :value
        attr_reader :path

        def initialize(value, path)
          @value = value
          @path = path

          super(
            "Value #{value} is not a recursive data structure and we have still #{path} keys " \
              'to look-up'
          )
        end
      end
    end
  end
end
