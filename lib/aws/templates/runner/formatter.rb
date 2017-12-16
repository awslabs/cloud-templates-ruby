require 'aws/templates/utils'

module Aws
  module Templates
    module Runner
      ##
      # Pluggable formatters
      #
      # The module contains formatter factory method and default formatter (AsIs) definition.
      # Formatters are classes implementing simple "format" method accepting object and returning
      # its' formatted string version.
      module Formatter
        ##
        # Dummy formatter
        #
        # Doesn't format object at all returning it as is.
        module AsIs
          def self.format(obj)
            obj
          end
        end

        def self.format_as(type, *params)
          require "aws/templates/runner/formatter/#{type.to_s.downcase}"
          const_get(type).new(*params)
        end

        def self.as_is
          AsIs
        end
      end
    end
  end
end
