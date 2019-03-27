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
          attr_accessor :scope

          def to_expression_by(_)
            self
          end

          def boxed_expression?
            true
          end

          def coerce(other)
            [scope.cast_for(other), self]
          end

          def initialize(scope)
            @scope = scope
          end
        end
      end
    end
  end
end
