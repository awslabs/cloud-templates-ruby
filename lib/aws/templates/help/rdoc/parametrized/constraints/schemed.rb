require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Parametrized
          module Constraints
            ##
            # Schemed constrained documentation abstract provider
            #
            # Prints keys and the constraints assigned to these keys of the schema.
            class Schemed < Parametrized::Constraint
              protected

              def add_description(item)
                item << text(header)
                item << _schema
              end

              def header
                raise 'Must be overriden'
              end

              private

              def _schema
                context.schema
                       .lazy
                       .map { |key, constraint| _constraint_for(key, constraint) }
                       .each_with_object(list) { |part, l| l << part }
              end

              def _constraint_for(key, constraint)
                if constraint.nil?
                  sub(text("_#{key}_"))
                else
                  sub(text("_#{key}_"), processed_for(constraint))
                end
              end
            end
          end
        end
      end
    end
  end
end
