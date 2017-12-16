require 'aws/templates/utils'

module UserDirectory
  module Render
    module Etc
      ##
      # Composite render
      #
      # It aggregates group and passwd entries from children and merges
      # them into single entry
      class CompositeView < ArtifactView
        artifact Aws::Templates::Composite

        def prepare
          rendered_for(instance.artifacts.values)
            .each_with_object(Diff.new([], [])) do |diff, memo|
              memo.passwd.concat(diff.passwd)
              memo.group.concat(diff.group)
              memo
            end
        end
      end
    end
  end
end
