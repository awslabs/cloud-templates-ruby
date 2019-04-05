require 'aws/templates/utils'
require 'concurrent/map'
require 'set'

module Aws
  module Templates
    module Processing
      ##
      # Abstract processor
      #
      # Processors are used in artifacts rendering and help generators. Processor embodies
      # functionality required to register an entity handler and look-up the registry when the
      # entity is processed.
      class Processor
        include Templates::Utils::Default

        extend Utils::Routing

        class <<self
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
          # Define handler for entity
          #
          # Another way to define handlers for entities. Creates anonymous class and attaches as
          # the handler to the specified entity.
          def define_handler(entity, handler, &blk)
            Class.new(handler, &blk).register_in(self).for_entity(entity)
          end

          def process(instance, params = nil)
            obj = params.nil? ? new : new(params)
            obj.process(instance)
          end

          ##
          # Add handlers
          #
          # Add routing between handlers and correspondent entities from another entity which
          # supports routing concept.
          def routing(routes)
            registry.merge(routes.registry)
          end

          def inherited(klass)
            super(klass)
            klass.routing(self)
          end
        end

        attr_reader :options

        def cache
          @cache ||= Concurrent::Map.new
        end

        def initialize(params = nil)
          @options = Templates::Utils::Options.new(defaults, params)
        end

        # Creates handler instance for given class with given context and parameters
        def handler_for(entity, params = nil)
          key = _key_for(entity, params)

          cache.compute_if_absent(key) do
            handler = handler_class_for(entity).new(self, entity, params)
            _finalize(entity, cache, key) unless _unfinalizable?(entity)
            handler
          end
        end

        ##
        # Handler look-up logic.
        #
        # Should provide logic for processing entities.
        def process(entity, params = nil)
          post_process(handler_for(entity, params).to_processed)
        end

        def self._entity_gc_hook(cache, key)
          ->(_) { cache.delete(key) }
        end

        protected

        def post_process(rendered)
          rendered
        end

        def handler_class_for(_entity)
          raise Templates::Exception::NotImplementedError.new('The method should be overriden')
        end

        private

        def _key_for(entity, params)
          entity.hash ^ entity.class.hash ^ params.hash
        end

        UNFINALIZABLE = [
          ::Symbol,
          ::TrueClass,
          ::FalseClass,
          ::Float,
          ::Integer,
          ::NilClass
        ].to_set.freeze

        def _unfinalizable?(obj)
          return true if obj.frozen?

          UNFINALIZABLE.include?(obj.class)
        end

        def _finalize(obj, cache, key)
          ObjectSpace.define_finalizer(obj, self.class._entity_gc_hook(cache, key))
        end
      end
    end
  end
end
