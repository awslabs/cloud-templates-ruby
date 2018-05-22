require 'json'
require 'aws/templates/utils'

module Aws
  module Templates
    ##
    # CLI namespace. See Cli::Processor
    module Cli
      def self.start(*args)
        Cli::Interface.start(*args)
      rescue StandardError => e
        explain_error(e)
        exit 1
      end

      def self.explain_error(exception)
        cursor = exception

        while cursor
          puts cursor
          puts
          cursor = cursor.cause
        end
      end
    end
  end
end
