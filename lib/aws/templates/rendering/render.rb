require 'aws/templates/utils'

module Aws
  module Templates
    module Rendering
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
      # Renders are classes which must be instantiated.
      #
      # === Example
      #
      #    class Wiki < Aws::Templates::Rendering::Render
      #    end
      #
      #    class JSON < Aws::Templates::Rendering::Render
      #    end
      class Render < Templates::Processing::Processor
        class <<self
          ##
          # Define view for artifact
          #
          # Another way to define views for artifacts. Creates anonymous class and attaches as
          # the view to the specified artifact
          def define_handler(artifact_class, view = nil, &blk)
            super(artifact_class, view || Rendering::BasicView, &blk)
          end

          alias define_view define_handler
        end

        protected

        def handler_class_for(instance)
          ancestor = instance.class.ancestors.find { |mod| self.class.handler?(mod) }

          raise Templates::Exception::ViewNotFound.new(instance) unless ancestor

          self.class.handler_for(ancestor)
        end
      end
    end
  end
end
