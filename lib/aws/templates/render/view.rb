module Aws
  module Templates
    module Render
      ##
      # Basic render view
      #
      # Views are classes encapsulating functionality of transforming
      # artifacts into domain-specific output. For instance, the same
      # LDAP record can be transformed into JSON description or LDIF definition.
      # Views can be attached to ancestors of an artifact and it expected
      # that the library will look-up the closest ancestor having view attached
      # if the render is invoked on a child.
      #
      # Each view is attached to a registry object which stores correspondence
      # between artifact classes and their views, and optionally to an artifact.
      # A view is registered in a registry only when it is attached to an artifact.
      # Views depend on artifacts but artifacts are not aware of views.
      # As the extreme case, a sole view can be attached to Artifact
      # if you have universal way to render your domain objects.
      #
      # Views are regular Ruby classes and all assumptions made about
      # polymorphism, inheritance and incapsulation are true for them.
      #
      # View class itself is an abstract class which can't be instantiated
      # directly.
      class BasicView
        ##
        # Render accessor
        #
        # Returns either render of this view class or render of any ancestor.
        def self.render
          @render || superclass.render
        end

        ##
        # Register the view class in a render
        #
        # Registers the view class in the render
        # * +r+ - render registrar
        def self.register_in(r)
          @render = r
          self
        end

        ##
        # Link the view class to the artifact class
        #
        # Registers the link in the render object of the view class.
        def self.artifact(artifact_class)
          render.register(artifact_class, self)
          self
        end

        ##
        # Artifact instance view object is attached to
        attr_reader :instance

        ##
        # Assigned view parameters
        attr_reader :parameters

        ##
        # Execute in the instance context
        #
        # Executed passed block in the context of the instance being rendered. It helps against
        # putting too much instance method accesses in long blocks. Returns the value returned by
        # the block.
        def in_instance(*args, &blk)
          instance.instance_exec(*args, &blk)
        end

        ##
        # Create view instance and link it to the artifact instance
        def initialize(obj, params = nil)
          @instance = obj
          @parameters = params
        end

        ##
        # Alias for class method render
        def render
          self.class.render
        end

        ##
        # Render the object
        #
        # Renders passed object with the view default render
        def rendered_for(obj, parameters_override = nil)
          render.view_for(obj, parameters_override.nil? ? parameters : parameters_override)
                .to_rendered
        end

        ##
        # Render the instance of the artifact
        #
        # The method should be overriden and return rendered form of the attached instance
        def to_rendered
          raise NotImplementedError.new('The method should be overriden')
        end
      end

      ##
      # Render view
      #
      # The class introduces additional stage called "prepare" where you can put prepared view
      # which will be additionally recursively rendered. Useful for complex views containing values
      # needed additional rendering so you don't need to invoke rendered_for.
      class View < BasicView
        ##
        # Render the instance of the artifact
        #
        # The method renders value returned by prepare
        def to_rendered
          rendered_for(prepare)
        end

        ##
        # Prepare value for rendering
        #
        # Should be overriden. Should return a value which is to be passed for final rendering.
        def prepare
          raise NotImplementedError.new('The method should be overriden')
        end
      end
    end
  end
end
