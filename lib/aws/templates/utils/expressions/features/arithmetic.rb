require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Expressions
        module Features
          ##
          # Arithmetic feature
          #
          # Mixin provides all basic operators appropriate for arithmetic expression.
          module Arithmetic
            include Features::Comparable

            def -@
              Expressions::Functions::Operations::Arithmetic::Negative.new(scope, self)
            end

            def +@
              self
            end

            def +(other)
              Expressions::Functions::Operations::Arithmetic::Addition.new(scope, self, other)
            end

            def -(other)
              Expressions::Functions::Operations::Arithmetic::Subtraction.new(scope, self, other)
            end

            def *(other)
              Expressions::Functions::Operations::Arithmetic::Multiplication.new(scope, self, other)
            end

            def /(other)
              Expressions::Functions::Operations::Arithmetic::Division.new(scope, self, other)
            end
          end
        end
      end
    end
  end
end
