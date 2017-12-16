require 'aws/templates/utils'
require 'concurrent/map'

module Aws
  module Templates
    module Render
      ##
      # View registry
      #
      # View registries encapsulate differerent ways of transforming
      # your artifacts into a domain-specific output.
      # In nutshell, they are registries of View classes which are able
      # to lookup proper View for object instance passed to it.
      class Registry
        # View registry accessor
        def registry
          @registry ||= Concurrent::Map.new
        end

        ##
        # Register pair artifact-view
        #
        # Invoked from inside of a View class at definition of the link
        # between the view class and an artifact
        # * +artifact+ - artifact class the view claims to be able to render
        # * +render+ - view class
        def register(artifact, view)
          registry.put_if_absent(artifact.name || artifact.reduce, view)
        end

        ##
        # Can object be rendered
        #
        # Returns true if the object passed can be rendered by one of the views in the registry
        def can_render?(instance)
          instance.class.ancestors.any? do |ancestor|
            registry[ancestor.name] || registry[ancestor]
          end
        end

        ##
        # Lookup a view for the artifact
        #
        # Searches registry for artifact's class and all its ancestors
        # in the registry and returns the closest matching view
        # * +instance+ - artifact instance to render
        # * +params+ - assigned parameters; it can be arbitrary value;
        #              it is propagated to selected render
        def view_for(instance, params = nil)
          return instance if instance.respond_to?(:to_rendered)

          view = instance.class.ancestors.find do |ancestor|
            view = registry[ancestor.name] || registry[ancestor]
            break view unless view.nil?
          end

          raise Templates::Exception::ViewNotFound.new(instance) unless view

          view.reduce.new(instance, params)
        end
      end
    end
  end
end
