require 'aws/templates/utils'

module Aws
  module Templates
    ##
    # Abstract processor
    #
    # Processors are used in artifacts rendering and help generators. Processor embodies
    # functionality required to register an entity handler and look-up the registry when the
    # entity is processed.
    module Processor
      include Routing

      ##
      # Proxy for Registry handler_for method
      def handler_for(*args)
        registry.handler_for(*args)
      end

      ##
      # Proxy for Registry handler? method
      def handler?(*args)
        registry.handler?(*args)
      end

      ##
      # Handlder look-up logic.
      #
      # Should provide logic for processing entities.
      def process(_entity, _params = nil)
        raise Templates::Exception::NotImplementedError.new('The method should be overriden')
      end

      ##
      # Define handler for entity
      #
      # Another way to define handlers for entities. Creates anonymous class and attaches as
      # the handler to the specified entity.
      def define_handler(entity, handler, &blk)
        Class.new(handler, &blk).register_in(self).for_entity(entity)
      end

      ##
      # Add handlers
      #
      # Add routing between handlers and correspondent entities from another entity which supports
      # routing concept.
      def routing(routes)
        registry.merge(routes.registry)
      end
    end
  end
end
