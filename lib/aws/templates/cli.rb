require 'json'
require 'aws/templates/utils'

module Aws
  module Templates
    ##
    # CLI namespace. See Cli::Processor
    module Cli
      def self.start(*args)
        Cli::Interface.start(*args)
      end
    end
  end
end
