require 'aws/templates/utils'

module Aws
  module Templates
    module Exception
      ##
      # Recursive value is expected
      #
      # Value passed doesn't not support "recursive" contract. See Utils.recursive?
      class OptionShouldBeRecursive < OptionError
        attr_reader :value

        def initialize(value)
          @value = value
          super("Value #{value} is not a recursive data structure")
        end
      end
    end
  end
end
