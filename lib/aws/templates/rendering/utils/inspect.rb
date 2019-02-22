require 'aws/templates/utils'

module Aws
  module Templates
    module Rendering
      module Utils
        ##
        # Render for object introspection
        #
        # Used by Inspectable to provide introspection mechanism (inspect) detached from the objects
        # themselves. Standard framework rendering mechanism is used.
        class Inspect < Rendering::Render
          extend Templates::Utils::Singleton

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
          class InspectView < Rendering::BasicView
            def depth
              (parameters.nil? ? Inspect.recursion_depth : Integer(parameters)) - 1
            end
          end

          ##
          # Simple inspection render
          #
          # Just returns inspected value unconditionally
          class SimpleInspect < Rendering::BasicView
            def to_processed
              instance.inspect
            end
          end

          define_view(::BasicObject, InspectView) do
            def to_processed
              depth.positive? ? instance.inspect : instance.to_s
            end
          end

          register(::NilClass, SimpleInspect)

          register(::String, SimpleInspect)

          register(::Numeric, SimpleInspect)

          define_view(::Hash, InspectView) do
            def to_processed
              if depth.positive?
                "{#{instance.map { |k, v| render_pair(k, v) }.join(',')}}"
              else
                instance.empty? ? '{}' : '{...}'
              end
            end

            def render_pair(key, value)
              "#{processed_for(key, depth)}: #{processed_for(value, depth)}"
            end
          end

          define_view(::Enumerable, InspectView) do
            def to_processed
              if depth.positive?
                "#{instance.class}[#{instance.map { |elem| processed_for(elem, depth) }.join(',')}]"
              else
                "#{instance.class}#{instance.empty? ? '[]' : '[...]'}"
              end
            end
          end

          define_view(Templates::Utils::Dependency::Depending, InspectView) do
            def to_processed
              'Dependency(' \
                "#{processed_for(instance.object, depth)}" \
                " => #{processed_for(instance.links, depth)})"
            end
          end

          define_view(Templates::Utils::Parametrized, InspectView) do
            def to_processed
              return instance.to_s unless depth.positive?

              "#{instance}" \
                "{parameters: #{processed_for(instance.parameters_map, depth)}," \
                " dependencies: #{processed_for(instance.dependencies, depth)}}"
            end
          end
        end
      end
    end
  end
end
