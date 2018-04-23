module Aws
  module Templates
    module Utils
      ##
      # Object with attached location of creation
      #
      # The mixin is used to attach location information to different DSL element instances
      # which were created by DSL factory nmethods. Used almost exclusively for error reporting
      module Scoped
        attr_accessor :scope
        attr_accessor :location

        def scoped?
          !scope.nil?
        end

        def located?
          !location.nil?
        end

        def source_location
          location ? [location.path, location.lineno] : ['(unknown)', nil]
        end
      end
    end
  end
end
