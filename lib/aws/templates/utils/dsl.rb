require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      ##
      # Gadget to create factory methods for DSL objects
      module Dsl
        ##
        # To add class methods also while including the module
        def elements(*modules)
          modules.each do |mod|
            define_method(mod.dsl_name) do |*args, &blk|
              mod.create_at_location(caller_locations[0..0].first, self, *args, &blk)
            end
          end
        end
      end
    end
  end
end
