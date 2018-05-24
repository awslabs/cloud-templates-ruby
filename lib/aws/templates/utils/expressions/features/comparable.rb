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
              Expressions::Functions::Operations::Comparisons::Greater.new(self, other)
            end

            def <(other)
              Expressions::Functions::Operations::Comparisons::Less.new(self, other)
            end

            def >=(other)
              Expressions::Functions::Operations::Comparisons::GreaterOrEqual.new(self, other)
            end

            def <=(other)
              Expressions::Functions::Operations::Comparisons::LessOrEqual.new(self, other)
            end

            def ==(other)
              Expressions::Functions::Operations::Comparisons::Equal.new(self, other)
            end

            def !=(other)
              Expressions::Functions::Operations::Comparisons::NotEqual.new(self, other)
            end

            def =~(other)
              Expressions::Functions::Operations::Range::Inside.new(self, other)
            end

            def !~(other)
              Expressions::Functions::Operations::Range::Outside.new(self, other)
            end
          end
        end
      end
    end
  end
end
