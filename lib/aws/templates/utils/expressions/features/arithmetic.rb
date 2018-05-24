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
              Expressions::Functions::Operations::Arithmetic::Negative.new(self)
            end

            def +@
              self
            end

            def +(other)
              Expressions::Functions::Operations::Arithmetic::Addition.new(self, other)
            end

            def -(other)
              Expressions::Functions::Operations::Arithmetic::Subtraction.new(self, other)
            end

            def *(other)
              Expressions::Functions::Operations::Arithmetic::Multiplication.new(self, other)
            end

            def /(other)
              Expressions::Functions::Operations::Arithmetic::Division.new(self, other)
            end
          end
        end
      end
    end
  end
end
