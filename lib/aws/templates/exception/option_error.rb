require 'aws/templates/utils'

module Aws
  module Templates
    module Exception
      ##
      # Options exception
      #
      # The parent of all exceptions Options method can throw
      class OptionError < ArgumentError
      end
    end
  end
end
