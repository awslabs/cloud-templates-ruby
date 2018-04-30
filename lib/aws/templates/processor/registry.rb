require 'aws/templates/utils'

module Aws
  module Templates
    module Processor
      ##
      # Handler registry
      #
      # Handler registries encapsulate differerent ways of transforming entities into
      # domain-specific output. In nutshell, they are registries of Handler classes which are able
      # to lookup proper Handler for a given entity.
      class Registry
        # Handler registry accessor
        def registry
          @registry ||= ::Concurrent::Map.new
        end

        ##
        # Register pair entity-handler
        #
        # Invoked from inside of a Handler class at definition of the link between the handler class
        # and an entity.
        # * +entity+ - entity the handler claims to be able to process
        # * +handler+ - handler class
        def register(entity, handler)
          registry.put_if_absent(_process_entity(entity), handler)
        end

        ##
        # Try to look-up the handler
        def handler_for(entity)
          handler = self[entity]
          raise "Handler is not found for #{entity}" unless handler
          handler.reduce
        end

        ##
        # Merge map with another recursive
        def merge(recursive)
          raise "#{recursive} is not recursive" unless Utils.recursive?(recursive)
          recursive.keys.each { |k| register(k, recursive[k]) }
          self
        end

        # All possible entity types
        def keys
          registry.keys
        end

        ##
        # Look-up the handler
        def [](entity)
          return registry[entity] unless entity.is_a?(Module)
          registry[entity.name] || registry[entity]
        end

        ##
        # Check if handler exists
        def include?(key)
          !self[key].nil?
        end

        alias handler? include?

        private

        def _process_entity(entity)
          return entity unless entity.is_a?(Module)
          entity.name || entity.reduce
        end
      end
    end
  end
end
