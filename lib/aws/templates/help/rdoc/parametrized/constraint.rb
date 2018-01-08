require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Parametrized
          ##
          # Abstract constraint provider
          #
          # Prints constraint-specific description and constraint condition.
          class Constraint < Rdoc::Provider
            for_entity Templates::Utils::Parametrized::Constraint

            def provide
              sub do |s|
                s << super unless add_description(s)
                condition_description = processed_for(context.pre_condition)
                s << condition_description if condition_description
              end
            end

            protected

            def add_description(_); end
          end
        end
      end
    end
  end
end
