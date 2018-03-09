require 'aws/templates/utils'

module Aws
  module Templates
    module Render
      module Utils
        ##
        # Utility views
        #
        # A collection of handful utility views which know how to flexibly render values into
        # specific types.
        module BaseTypeViews
          include Render
          using Templates::Utils::Dependency::Refinements

          ##
          # Pass-through render
          class AsIs < Render::BasicView
            def to_rendered
              instance.object
            end
          end

          ##
          # Convert to string
          class ToString < Render::BasicView
            def to_rendered
              instance.to_s
            end
          end

          ##
          # Convert to array
          #
          # Converts value to array and iteratively renders every element in it.
          class ToArray < Render::BasicView
            def to_rendered
              instance
                .to_a
                .map { |element| processed_for(element) }
            end
          end

          ##
          # Convert to hash
          #
          # Converts value to hash and iteratively renders each key and value in it.
          class ToHash < Render::BasicView
            def to_rendered
              _from(instance).map { |k, v| [processed_for(k), processed_for(v)] }.to_h
            end

            private

            def _from(obj)
              if obj.respond_to?(:to_h)
                instance.to_h
              else
                instance.to_hash
              end
            end
          end

          ##
          # Convert to float
          class ToFloat < Render::BasicView
            def to_rendered
              instance.to_f
            end
          end

          ##
          # Convert to integer
          class ToInteger < Render::BasicView
            def to_rendered
              instance.to_i
            end
          end

          ##
          # Convert to boolean
          class ToBoolean < Render::BasicView
            def to_rendered
              !instance.to_s.casecmp('false').zero?
            end
          end

          DEFAULT_RENDERING_MAP = {
            ::String => AsIs,
            ::Float => AsIs,
            ::Integer => AsIs,
            ::TrueClass => AsIs,
            ::FalseClass => AsIs,
            ::NilClass => AsIs,
            ::Symbol => AsIs,
            Aws::Templates::Utils::Dependency::Depending => AsIs,
            ::Array => ToArray,
            ::Hash => ToHash,
            Aws::Templates::Utils::Options => ToHash
          }.freeze

          ##
          # Set all default views
          #
          # Set all default views for defined types. Views module class definitions are used
          def initialize_base_type_views
            DEFAULT_RENDERING_MAP.each_pair { |klass, view| define_view(klass, view) }
          end

          ##
          # Set default views for specific classes
          #
          # Set default views only for passed types.
          def initialize_base_type_views_for(*classes)
            classes.each do |k|
              raise "Can't find default view for class #{k}" unless DEFAULT_RENDERING_MAP.key?(k)
              define_view(k, DEFAULT_RENDERING_MAP[k])
            end
          end
        end
      end
    end
  end
end
