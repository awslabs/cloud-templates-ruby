require 'aws/templates/utils'
require 'facets/string/pathize'

module Aws
  module Templates
    module Cli
      ##
      # Pluggable formatters
      #
      # The module contains formatter factory method and default formatter (AsIs) definition.
      # Formatters are classes implementing simple "format" method accepting object and returning
      # its' formatted string version.
      module Formatter
        def self.format_as(type, *params)
          require "aws/templates/cli/formatter/#{type.pathize}"
          const_get(type).new(*params)
        end
      end
    end
  end
end
