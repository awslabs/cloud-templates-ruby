require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Default
          ##
          # Default's definition documentation provider
          class Definition < Rdoc::Provider
            using Templates::Utils::Default::Refinements

            for_entity Templates::Utils::Default::Definition

            ##
            # Empty definition provider
            #
            # Doesn't provide actually anything. Returns nil.
            class Empty < Definition
              register_in Rdoc
              for_entity Templates::Utils::Default::Definition::Empty

              def provide; end
            end

            ##
            # Combined definition documentation provider
            #
            # Composes left and right component of the pair into a documentation block.
            class Pair < Definition
              register_in Rdoc
              for_entity Templates::Utils::Default::Definition::Pair

              def provide
                sub do |s|
                  _add_parts(context.a, s)
                  s << text('_overlayed_ _with_')
                  _add_parts(context.b, s)
                end
              end

              private

              def _add_parts(side, container)
                processed_for(side).parts.each { |part| container << part }
              end
            end

            ##
            # Scalar/override documentation provider
            #
            # Just generates documentation for the scalar.
            class Scalar < Definition
              for_entity Templates::Utils::Default::Definition::Scalar

              def provide
                processed_for(context.value)
              end
            end

            ##
            # Calculable documentation provider
            #
            # Generates documentation for the given code block.
            class Calculable < Definition
              for_entity Templates::Utils::Default::Definition::Calculable

              def provide
                processed_for(context.block)
              end
            end

            ##
            # Scheme documentation provider
            #
            # Generates documentation for the given defaults scheme.
            class Scheme < Definition
              for_entity Templates::Utils::Default::Definition::Scheme

              def provide
                processed_for(context.scheme)
              end
            end
          end
        end
      end
    end
  end
end
