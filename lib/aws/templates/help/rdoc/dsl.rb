require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        ##
        # Documentation blurb provider
        #
        # Outputs description blurb attached to the object in a separate text block.
        class Dsl < Rdoc::Provider
          def provide
            return if context.help.nil?
            sub(text('_Description_'), parsed_for(context.help))
          end
        end
      end
    end
  end
end
