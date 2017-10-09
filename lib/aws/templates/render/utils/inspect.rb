require 'aws/templates/render'
require 'aws/templates/utils/parametrized'
require 'aws/templates/utils/dependency'

module Aws
  module Templates
    module Render
      module Utils
        ##
        # Render for object introspection
        #
        # Used by Inspectable to provide introspection mechanism (inspect) detached from the objects
        # themselves. Standard framework rendering mechanism is used.
        module Inspect
          extend Aws::Templates::Render

          DEFAULT_RECURSION_DEPTH = 3

          def self.recursion_depth
            @recursion_depth || DEFAULT_RECURSION_DEPTH
          end

          def self.recursion_depth=(depth)
            @recursion_depth = Integer(depth)
          end

          ##
          # Basic inspection render
          #
          # Defines "depth" property which is used to control recursion depth during object
          # introspection.
          class InspectView < BasicView
            def depth
              (Integer(parameters) || Inspect.recursion_depth) - 1
            end
          end

          define_view(::Object, InspectView) do
            def to_rendered
              depth > 0 ? instance.inspect : instance.to_s
            end
          end

          define_view(::Hash, InspectView) do
            def to_rendered
              if depth > 0
                "{#{instance.map { |k, v| render_pair(k, v) }.join(',')}}"
              else
                instance.empty? ? '{}' : '{...}'
              end
            end

            def render_pair(k, v)
              "#{rendered_for(k, depth)}: #{rendered_for(v, depth)}"
            end
          end

          define_view(::Enumerable, InspectView) do
            def to_rendered
              if depth > 0
                "#{instance.class}[#{instance.map { |elem| rendered_for(elem, depth) }.join(',')}]"
              else
                "#{instance.class}#{instance.empty? ? '[]' : '[...]'}"
              end
            end
          end

          define_view(Templates::Utils::Dependency, InspectView) do
            def to_rendered
              'Dependency(' \
                "#{rendered_for(instance.object, depth)}" \
                " => #{rendered_for(instance.dependencies, depth)})"
            end
          end

          define_view(Templates::Utils::Parametrized, InspectView) do
            def to_rendered
              return instance.to_s unless depth > 0
              "#{instance}" \
                "{parameters: #{rendered_for(instance.parameters_map, depth)}," \
                " dependencies: #{rendered_for(instance.dependencies, depth)}}"
            end
          end
        end
      end
    end
  end
end
