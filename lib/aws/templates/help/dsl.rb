require 'aws/templates/utils'
require 'facets/string/indent'

module Aws
  module Templates
    module Help
      ##
      # Help description DSL
      #
      # Mixin to construct inheritable help documentation which can be rendered through
      # standard rendering framework allowing different types of output to be produced.
      module Dsl
        include Templates::Utils::Inheritable

        instance_scope do
          def help
            self.class.help
          end
        end

        class_scope do
          def help(str = nil)
            return @help if str.nil?
            @help = str.unindent
          end
        end
      end
    end
  end
end
