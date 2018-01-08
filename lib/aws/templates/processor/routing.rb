require 'aws/templates/utils'

module Aws
  module Templates
    module Processor
      ##
      # Routing DSL
      #
      # Defines trivial methods to wire handlers with respective entities.
      module Routing
        ##
        # Registry accessor
        #
        # All handlers and corresponding entities in a processor are stored in a registry.
        def registry
          @registry ||= Processor::Registry.new
        end

        ##
        # Proxy for Registry register method
        def register(*args)
          registry.register(*args)
        end
      end
    end
  end
end
