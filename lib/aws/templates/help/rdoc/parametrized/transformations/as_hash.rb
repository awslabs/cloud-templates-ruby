require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Parametrized
          module Transformations
            ##
            # Hash transformation documentation
            #
            # Outputs documentation blocks for key and value sub-parameters.
            class AsHash < Rdoc::Parametrized::Transformation
              for_entity Templates::Utils::Parametrized::Transformation::AsHash

              def to_processed
                return sub(text('as a hash')) if context.definition.nil?

                sub(text('as a hash where:'), key_value_description)
              end

              private

              def key_value_description
                list(
                  :BULLET,
                  description_for('key', context.definition.key_parameter),
                  description_for('value', context.definition.value_parameter)
                )
              end

              def description_for(name, value)
                return sub(text("_#{name}_ can be anything")) if value.nil?

                processed_for(value)
              end
            end
          end
        end
      end
    end
  end
end
