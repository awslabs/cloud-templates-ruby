require 'aws/templates/utils'

module Aws
  module Templates
    module Processing
      ##
      # Basic entity handler
      #
      # Handler are classes encapsulating functionality of transforming entity into desired output.
      # For instance, the same LDAP record can be transformed into JSON description or LDIF
      # definition. The same help article can be written to output console or HTML.
      #
      # Each handler is attached to a registry object which stores correspondence
      # between entities and their handlers. A handler is registered in a registry only when it is
      # attached to an entity. Handler depend on entities but entities are not aware of handlers.
      #
      # Handlers are regular Ruby classes and all assumptions made about polymorphism, inheritance
      # and incapsulation are true for them.
      #
      # Handler class itself is an abstract class which can't be instantiated directly.
      class Handler
        class << self
          ##
          # Render accessor
          #
          # Returns either processor of this handler class or processor of any ancestor.
          def processor
            @processor || (superclass.processor if superclass < Handler)
          end

          ##
          # Register the hander class in a processor
          #
          # Registers the handler class in the processor
          # * +r+ - processor registrar
          def register_in(registrar)
            @processor = registrar
            self
          end

          ##
          # Link the handler class to the entity
          #
          # Registers the link in the processor object of the handler class.
          def for_entity(entity)
            @entity = entity
            processor.register(entity, self)
            self
          end

          ##
          # Entity the handler is registered for
          attr_reader :entity
        end

        ##
        # Context handler object is attached to
        attr_reader :context

        ##
        # Assigned handler parameters
        attr_reader :parameters

        ##
        # Assigned processor instance
        attr_reader :parent

        ##
        # Execute in the context
        #
        # Executes passed block in the context. It helps against putting too much context-dependend
        # method accesses in long blocks. Returns the value returned by the block.
        def in_context(*args, &blk)
          context.instance_exec(*args, &blk)
        end

        ##
        # Create handler instance and link it to the context
        def initialize(parent, ctx, params = nil)
          raise 'Parent can\'t be nil' if parent.nil?

          @parent = parent
          @context = ctx
          @parameters = params
        end

        ##
        # Process the object
        #
        # Processes passed object with the handler default processor
        def processed_for(obj, parameters_override = nil)
          handler = handler_for(obj, parameters_override.nil? ? parameters : parameters_override)
          handler.to_processed
        end

        ##
        # Get handler for the entity
        #
        # Returns registered handler for the entity
        def handler_for(*args)
          parent.handler_for(*args)
        end

        def to_processed
          raise Templates::Exception::NotImplementedError.new('The method should be overriden')
        end
      end
    end
  end
end
