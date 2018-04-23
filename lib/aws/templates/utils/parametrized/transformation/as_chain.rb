require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Parametrized
        class Transformation
          ##
          # Apply several transformation sequentially
          #
          # Useful when a few transformations need to be applied to a single value to get
          # the final result
          #
          # === Example
          #
          #    class Piece
          #      include Aws::Templates::Utils::Parametrized
          #
          #      parameter :param,
          #        transform: as_chain(
          #                     as_hash,
          #                     as_object(Aws::Templates::Utils::AsNamed)
          #                   )
          #    end
          #
          #    i = Piece.new(param: [:name, 'Rex'])
          #    i.param.name # => 'Rex'
          class AsChain < self
            attr_reader :components

            def initialize(*components)
              @components = _check_components(components)
            end

            protected

            def transform(value, instance)
              return if value.nil?
              components.inject(value) { |acc, elem| instance.instance_exec(acc, &elem) }
            end

            private

            def _check_components(components)
              result = components.to_a

              invalid_components = result.reject { |component| component.respond_to?(:to_proc) }
              raise "Invalid components: #{invalid_components}" unless invalid_components.empty?

              result
            end
          end
        end
      end
    end
  end
end
