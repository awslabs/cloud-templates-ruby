require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Parametrized
          ##
          # Concept documentation provider
          #
          # Prints documentation for included constraint and transformation.
          class Concept < Rdoc::Provider
            for_entity Templates::Utils::Parametrized::Concept

            ##
            # Chained concept documentation provider
            #
            # Prints documentation for the concepts in the chain
            class Chain < Rdoc::Provider
              for_entity Templates::Utils::Parametrized::Concept::Chain

              def provide
                list(:BULLET) do |l|
                  concepts.each { |concept| l << processed_for(concept) }
                end
              end
            end

            def provide
              sub(
                list(:BULLET) do |l|
                  add_transformation(l)
                  add_constraint(l)
                end
              )
            end

            protected

            def add_transformation(lst)
              return unless context.transform

              lst << sub(text('transformation:'), processed_for(context.transform))
            end

            def add_constraint(lst)
              return unless context.constraint

              lst << sub(text('constraint:'), processed_for(context.constraint))
            end
          end
        end
      end
    end
  end
end
