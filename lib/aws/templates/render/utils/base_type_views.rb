require 'aws/templates/render'
require 'aws/templates/render/view'
require 'aws/templates/utils'
require 'aws/templates/utils/dependency'
require 'aws/templates/utils/options'

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

          ##
          # Pass-through render
          class AsIs < BasicView
            def to_rendered
              instance.object
            end
          end

          ##
          # Convert to string
          class ToString < BasicView
            def to_rendered
              instance.to_s
            end
          end

          ##
          # Convert to array
          #
          # Converts value to array and iteratively renders every element in it.
          class ToArray < BasicView
            def to_rendered
              instance
                .to_a
                .map { |element| render.view_for(element, parameters).to_rendered }
            end
          end

          ##
          # Convert to hash
          #
          # Converts value to hash and iteratively renders each key and value in it.
          class ToHash < BasicView
            def to_rendered
              _from(instance).map { |k, v| [_to_rendered(k), _to_rendered(v)] }.to_h
            end

            private

            def _from(obj)
              if obj.respond_to?(:to_h)
                instance.to_h
              else
                instance.to_hash
              end
            end

            def _to_rendered(obj)
              render.view_for(obj, parameters).to_rendered
            end
          end

          ##
          # Convert to float
          class ToFloat < BasicView
            def to_rendered
              instance.to_f
            end
          end

          ##
          # Convert to integer
          class ToInteger < BasicView
            def to_rendered
              instance.to_i
            end
          end

          ##
          # Convert to boolean
          class ToBoolean < BasicView
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
            Templates::Utils::Dependency => AsIs,
            ::Array => ToArray,
            ::Hash => ToHash,
            Templates::Utils::Options => ToHash
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
