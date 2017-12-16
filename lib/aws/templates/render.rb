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
      ##
      # Registry accessor
      #
      # All views and corresponding artifacts in a render are stored
      # in a registry.
      def registry
        @registry ||= Registry.new
      end

      ##
      # Proxy for Registry register method
      def register(*args)
        registry.register(*args)
      end

      ##
      # Proxy for Registry can_render? method
      def can_render?(*args)
        registry.can_render?(*args)
      end

      ##
      # Proxy for Registry view_for method
      def view_for(*args)
        registry.view_for(*args)
      end

      ##
      # Define view for artifact
      #
      # Another way to define views for artifacts. Creates anonymous class and attaches as the view
      # to the specified artifact
      def define_view(artifact_class, view = nil, &blk)
        Class
          .new(view || Aws::Templates::Render::BasicView, &blk)
          .register_in(self)
          .artifact(artifact_class)
      end
    end
  end
end
