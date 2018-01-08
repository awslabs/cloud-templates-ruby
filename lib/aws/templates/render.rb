require 'aws/templates/utils'

module Aws
  module Templates
    ##
    # View layer of the MVC pattern
    #
    # View layer provides means of defining "views" of your artifacts
    # to define different ways of rendering the object hierarchies you
    # create to end representation.
    #
    # The module also contains a few mixin methods to simplify creation
    # of "renders" - collections of views defining the same domain
    # representation. For instance JSON, LDIF, Wiki could be such
    # final destinations.
    #
    # Renders could be classes or modules. Modules work best if no
    # customization is needed and you want a singleton.
    #
    # === Example
    #
    #    class Wiki
    #      include Aws::Templates::Render
    #    end
    #
    #    module JSON
    #      extend Aws::Templates::Render
    #    end
    module Render
      include Templates::Processor

      ##
      # Can object be rendered
      #
      # Returns true if the object passed can be rendered by one of the views in the registry
      def can_render?(instance)
        instance.class.ancestors.any? { |ancestor| handler?(ancestor) }
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

        ancestor = instance.class.ancestors.find { |mod| handler?(mod) }

        raise Templates::Exception::ViewNotFound.new(instance) unless ancestor

        handler_for(ancestor).new(instance, params)
      end

      def process(entity, params = nil)
        view_for(entity, params).to_rendered
      end

      ##
      # Define view for artifact
      #
      # Another way to define views for artifacts. Creates anonymous class and attaches as the view
      # to the specified artifact
      def define_handler(artifact_class, view = nil, &blk)
        super(artifact_class, view || BasicView, &blk)
      end

      alias define_view define_handler
    end
  end
end
