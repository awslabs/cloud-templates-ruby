require 'aws/templates/utils'

module Aws
  module Templates
    module Exception
      ##
      # Parameter definition exception
      #
      # Meta-programming exception related to Parametrized DSL
      class ParametrizedDslError < StandardError
      end
    end
  end
end
