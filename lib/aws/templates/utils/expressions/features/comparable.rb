require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Expressions
        module Features
          ##
          # Comparable features
          #
          # The mixin provides operations appropriate for ordered entities which can be compared.
          module Comparable
            def >(other)
              Expressions::Functions::Operations::Comparisons::Greater.new(scope, self, other)
            end

            def <(other)
              Expressions::Functions::Operations::Comparisons::Less.new(scope, self, other)
            end

            def >=(other)
              Expressions::Functions::Operations::Comparisons::GreaterOrEqual.new(
                scope, self, other
              )
            end

            def <=(other)
              Expressions::Functions::Operations::Comparisons::LessOrEqual.new(scope, self, other)
            end

            def ==(other)
              Expressions::Functions::Operations::Comparisons::Equal.new(scope, self, other)
            end

            def !=(other)
              Expressions::Functions::Operations::Comparisons::NotEqual.new(scope, self, other)
            end

            def =~(other)
              Expressions::Functions::Operations::Range::Inside.new(scope, self, other)
            end

            def !~(other)
              Expressions::Functions::Operations::Range::Outside.new(scope, self, other)
            end
          end
        end
      end
    end
  end
end
