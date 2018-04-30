require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Parametrized
          ##
          # Parameter documentation provider
          #
          # Combines parameter description and documentation blocks for constraint, getter and
          # transformation if they are assigned to the parameter.
          class Parameter < Rdoc::Provider
            for_entity Templates::Utils::Parametrized::Parameter

            def provide
              sub(description) do |s|
                s << list(:BULLET) do |l|
                  add_transformation(l)
                  add_constraint(l)
                end
              end
            end

            private

            def description
              desc = "_#{context.name}_ "
              desc.concat(context.description) if context.description
              text(desc)
            end

            def add_transformation(lst)
              return unless context.transform

              lst << sub(
                text('transformation:'),
                processed_for(context.transform)
              )
            end

            def add_constraint(lst)
              return unless context.constraint

              lst << sub(
                text('constraint:'),
                processed_for(context.constraint)
              )
            end
          end
        end
      end
    end
  end
end
