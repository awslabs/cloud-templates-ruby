require 'aws/templates/utils'

module Aws
  module Templates
    module Help
      module Rdoc
        ##
        # Composite documentation provider
        #
        # Does the same as Artifact documentation aggregate adding context filters section as an
        # aspect
        class Composite < Rdoc::Artifact
          for_entity Templates::Composite

          after Templates::Utils::Contextualized
        end
      end
    end
  end
end
