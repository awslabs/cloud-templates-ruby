require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Dependency
        ##
        # Object dependency attachment
        #
        # It is used to create singleton classes attached to objects to track dependencies.
        module SingletonMixin
          include Utils::Dependency::Depending

          def object
            dup
          end
        end
      end
    end
  end
end
