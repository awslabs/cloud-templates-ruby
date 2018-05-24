require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Expressions
        module Variables
          ##
          # Arithmetic variable
          #
          # Variable with Arithmetic feature included so comparison and arithmetic operations are
          # available for it
          #
          # Example:
          #
          #    v = Arithmetic.new(:v)
          #
          #    v + 1
          #    v > 1
          class Arithmetic < Expressions::Variable
            include Expressions::Features::Arithmetic
          end
        end
      end
    end
  end
end
