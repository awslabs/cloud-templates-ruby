require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Parametrized
          module Constraints
            ##
            # Is constraint documentation provider
            #
            # Prints defined class and fields constraints.
            class Is < Parametrized::Constraint
              for_entity Templates::Utils::Parametrized::Constraint::Is

              protected

              def add_description(item)
                item << text('should be an instance of:')
                item << _selector
              end

              private

              def _selector
                context.selector
                       .lazy
                       .map { |klass, attributes| _attributes_for(klass, attributes) }
                       .each_with_object(list) { |part, l| l << part }
              end

              def _attributes_for(klass, attributes)
                if attributes.nil?
                  sub(text("_#{klass}_"))
                else
                  sub(text("_#{klass}_"), _attributes(attributes))
                end
              end

              def _attributes(attributes)
                attributes
                  .lazy
                  .map { |attribute| _constraint_for(attribute.name, attribute.constraint) }
                  .each_with_object(list) { |part, l| l << part }
              end

              def _constraint_for(name, constraint)
                sub(text("_#{name}_ :"), processed_for(constraint))
              end
            end
          end
        end
      end
    end
  end
end
