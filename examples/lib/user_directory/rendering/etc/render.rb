require 'aws/templates/utils'

module UserDirectory
  module Rendering
    module Etc
      ##
      # UNIX passwd/group render
      #
      # Transforms formed catalog artifacts into standard UNIX passwd/group
      # representation.
      class Render < Aws::Templates::Rendering::Render
        extend Aws::Templates::Rendering::Utils::BaseTypeViews
        initialize_base_type_views
        register ::Pathname, Aws::Templates::Rendering::Utils::BaseTypeViews::ToString

        ##
        # Diff view
        #
        # Creates Diff object out of the instance attached with recursively rendered passwd
        # and group fields.
        class DiffView < Aws::Templates::Rendering::BasicView
          register_in Render
          artifact Etc::Diff

          def to_processed
            Diff.new rendered_for(instance.passwd), rendered_for(instance.group)
          end
        end
      end
    end
  end
end
