require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      ##
      # Abstract help provider
      class Provider < Templates::Processor::Handler
        def provide
          raise Templates::Exception::NotImplementedError.new('The method should be overriden')
        end
      end
    end
  end
end
