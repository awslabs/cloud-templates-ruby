require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        ##
        # Abstract Rdoc provider
        class Provider < Help::Provider
          register_in Rdoc::Processor
          include Rdoc::Texting

          def to_processed
            text "#{context.class.name} (No specific documentation found)"
          end
        end
      end
    end
  end
end
