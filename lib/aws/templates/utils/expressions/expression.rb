require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Expressions
        ##
        # Basic Expression
        #
        # Contains functionality common to all boxed expressions. It provides flag methods and
        # type coercion.
        module Expression
          using Refinements

          def boxable_expression?
            true
          end

          def to_boxed_expression
            self
          end

          def coerce(other)
            [other.to_boxed_expression, self]
          end
        end
      end
    end
  end
end
