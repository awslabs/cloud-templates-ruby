require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Parametrized
        class Transformation
          ##
          # Transform value with the specified render
          #
          # Input value can be anything which could be rendered by the
          # specified render type. Returned value is rendered input.
          #
          # The transformation is useful when you have a document of some
          # format embedded into a document of another format. An example
          # could be Bash scripts embedded into AWS CFN template.
          #
          # === Example
          #
          #    class Brush
          #      attr_reader :color
          #      attr_reader :thickness
          #      attr_reader :type
          #
          #      def initialize(c, thick, t)
          #        @c = c
          #        @thick = thick
          #        @t = t
          #      end
          #    end
          #
          #    class Circle
          #      attr_reader :radius
          #      attr_reader :brush
          #
          #      def initialize(r, b)
          #        @radius = r
          #        @brush = b
          #      end
          #    end
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #
          #      parameter :picture, :transform => as_rendered(
          #        # Render Type
          #        Graphics::Renders::JPEG,
          #        # parameter section for the render
          #        format: :base64
          #      )
          #    end
          #
          #    i = Piece.new(picture: Circle.new(10, Brush.new(:red, 2, :dots)))
          #    i.picture # => <rendered representation>
          class AsRendered < self
            attr_reader :render
            attr_reader :parameters

            def initialize(render, params = nil, &params_block)
              @render = _check_render(render)
              @parameters = params || params_block
            end

            protected

            def transform(value, instance)
              return if value.nil?

              render.process(value, _compute_render_parameters(instance))
            end

            private

            def _check_render(render)
              unless render.respond_to?(:process)
                raise(
                  "Wrong render type object #{render}. " \
                  'The instance should have #view_for method.'
                )
              end

              render
            end

            def _compute_render_parameters(instance)
              return if parameters.nil?

              if parameters.respond_to?(:to_hash)
                parameters
              elsif parameters.respond_to?(:to_proc)
                instance.instance_exec(&parameters)
              else
                parameters
              end
            end
          end
        end
      end
    end
  end
end
