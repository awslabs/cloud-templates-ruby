require 'aws/templates/utils'

module Aws
  module Templates
    module Rendering
      ##
      # Render view
      #
      # The class introduces additional stage called "prepare" where you can put prepared view
      # which will be additionally recursively rendered. Useful for complex views containing values
      # needed additional rendering so you don't need to invoke rendered_for.
      class View < Rendering::BasicView
        ##
        # Render the instance of the artifact
        #
        # The method renders value returned by prepare
        def to_processed
          processed_for(prepare)
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
