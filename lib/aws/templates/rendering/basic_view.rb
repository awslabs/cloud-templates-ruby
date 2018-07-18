require 'aws/templates/utils'

module Aws
  module Templates
    module Rendering
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
      class BasicView < Templates::Processing::Handler
        class << self
          alias artifact for_entity
        end

        alias instance context
        alias in_instance in_context
        alias rendered_for processed_for
        alias to_rendered to_processed
      end
    end
  end
end
