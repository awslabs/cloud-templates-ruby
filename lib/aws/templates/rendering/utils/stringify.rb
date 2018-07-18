require 'aws/templates/utils'

module Aws
  module Templates
    module Rendering
      module Utils
        ##
        # Stringifying render
        #
        # Used by Inspectable module to provide stringification mechanism (to_s) detached from
        # the objects themselves. Standard framework rendering mechanism is used.
        class Stringify < Rendering::Render
          extend Templates::Utils::Singleton

          define_view(::Object) do
            def to_processed
              instance.class.name
            end
          end

          define_view(::Aws::Templates::Utils::Dependency::Depending) do
            def to_processed
              instance.object.to_s
            end
          end

          define_view(Templates::Artifact) do
            def to_processed
              "#{instance.class}(#{instance.lookup_path.map(&:inspect).join('/')})"
            end
          end

          define_view(Templates::Utils::Parametrized::Nested) do
            def to_processed
              "#{instance.class}(in: #{instance.parent})"
            end
          end
        end
      end
    end
  end
end
