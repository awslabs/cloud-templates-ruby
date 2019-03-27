require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Expressions
        module Features
          ##
          # Logical feature
          #
          # The mixin contains operations appropriate for logical expression.
          module Logical
            include Expressions::Flags::Logical

            def |(other)
              Expressions::Functions::Operations::Logical::Or.new(scope, self, other)
            end

            def &(other)
              Expressions::Functions::Operations::Logical::And.new(scope, self, other)
            end

            def !
              Expressions::Functions::Operations::Logical::Not.new(scope, self)
            end
          end
        end
      end
    end
  end
end
