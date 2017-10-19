require 'aws/templates/render'
require 'aws/templates/artifact'
require 'aws/templates/utils/parametrized/nested'
require 'aws/templates/utils/dependency'

module Aws
  module Templates
    module Render
      module Utils
        ##
        # Stringifying render
        #
        # Used by Inspectable module to provide stringification mechanism (to_s) detached from
        # the objects themselves. Standard framework rendering mechanism is used.
        module Stringify
          extend Aws::Templates::Render

          define_view(::Object) do
            def to_rendered
              instance.class.name
            end
          end

          define_view(::Aws::Templates::Utils::Dependency) do
            def to_rendered
              instance.object.to_s
            end
          end

          define_view(Templates::Artifact) do
            def to_rendered
              "#{instance.class}(#{instance.lookup_path.map(&:inspect).join('/')})"
            end
          end

          define_view(Templates::Utils::Parametrized::Nested) do
            def to_rendered
              "#{instance.class}(in: #{instance.parent})"
            end
          end
        end
      end
    end
  end
end
