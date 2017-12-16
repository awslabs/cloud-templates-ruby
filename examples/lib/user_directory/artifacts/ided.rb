require 'aws/templates/utils'

module UserDirectory
  module Artifacts
    ##
    # Parameter mixin containing universal parameters for indexed objects
    module Ided
      include Aws::Templates::Utils::Parametrized
      parameter :id, description: 'Object ID', constraint: not_nil
    end
  end
end
