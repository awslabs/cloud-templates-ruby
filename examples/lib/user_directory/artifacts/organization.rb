require 'aws/templates/utils'

module UserDirectory
  module Artifacts
    ##
    # Catalog's organization
    class Organization < Aws::Templates::Composite
      include Artifacts::Catalogized

      default dn: proc { "o=#{name}" }
      parameter :name, description: 'Organization name', constraint: not_nil

      contextualize filter(:override) { { organization: self, unit: self } }
    end
  end
end
