require 'aws/templates/utils'

module UserDirectory
  module Artifacts
    ##
    # Parameter mixin containing universal catalog entry fields
    module Catalogized
      include Aws::Templates::Utils::Parametrized
      parameter :dn, description: 'Object distinguished name', constraint: not_nil
    end
  end
end
