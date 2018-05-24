require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Expressions
        module Variables
          ##
          # Logical variable
          #
          # Variable with Logical feature included so logical operations are available for it.
          #
          # Example:
          #
          #    v = Logical.new(:v)
          #
          #    v & true
          #    !v
          class Logical < Expressions::Variable
            include Expressions::Features::Logical
          end
        end
      end
    end
  end
end
