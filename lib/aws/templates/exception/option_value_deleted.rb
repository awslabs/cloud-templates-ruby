require 'aws/templates/utils'

module Aws
  module Templates
    module Exception
      ##
      # Deleted branch detected
      #
      # While traversing Options layers for a value, deleted branch marker was discovered.
      class OptionValueDeleted < OptionError
        attr_reader :path

        def initialize(path)
          @path = path
          super(
            "Deleted value was detected while traversing path. The path left untraversed: #{path}"
          )
        end
      end
    end
  end
end
