require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Expressions
        ##
        # Boxed numeric
        #
        # Since it's not possible to modify singletons of numbers, we are using the Proxy technique
        # to add additional methods to numerical values.
        class Boolean < Utils::Proxy
          include Expressions::Expression
          include Expressions::Features::Logical

          alias unbox delegate

          def initialize(scope, value)
            super(scope)
            @delegate = value
          end
        end
      end
    end
  end
end
