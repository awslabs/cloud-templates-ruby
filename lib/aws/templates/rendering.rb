module Aws
  module Templates
    ##
    # Namespace for rendering subsystem
    #
    # Rendering is a type of processing which transforms a model into a representation of the
    # object.
    module Rendering
      def self.types
        Templates::Utils::Extender.create_for(self).map(:types).flatten
      end
    end
  end
end
