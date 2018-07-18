require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        module Contextualized
          module Filters
            ##
            # Common class for schema-based filters
            #
            # Outputs schema object with specified blurb as the header.
            class RecursiveSchemaFilter < Contextualized::Filter
              def self.blurb(str = nil)
                return @description_blurb if str.nil?
                @description_blurb = str
              end

              def to_processed
                sub(text(self.class.blurb), processed_for(context.scheme))
              end
            end
          end
        end
      end
    end
  end
end
