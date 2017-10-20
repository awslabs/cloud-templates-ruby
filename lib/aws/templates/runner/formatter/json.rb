require 'json'

module Aws
  module Templates
    module Runner
      module Formatter
        ##
        # JSON formatter
        #
        # Transforms passed object into valid JSON document
        class JSON
          def format(obj)
            obj.to_json
          end
        end
      end
    end
  end
end
