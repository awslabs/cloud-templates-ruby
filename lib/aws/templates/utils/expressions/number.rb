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
        class Number < Utils::Proxy
          include Expressions::Expression
          include Expressions::Features::Arithmetic

          alias unbox delegate

          def initialize(value)
            @delegate = value
          end
        end
      end
    end
  end
end
