require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Contextualized
        ##
        # Filter transformation refinements
        #
        # Contains standard object refinements to transform their instances into scope filters.
        module Refinements
          ##
          # Hash class patch
          #
          # Adds to_filter method converting a hash into an Override filter
          refine ::Hash do
            ##
            # Convert to Override filter
            def to_filter
              Aws::Templates::Utils::Contextualized::Filter::Override.new(self)
            end
          end

          ##
          # NilClass class patch
          #
          # Adds to_filter method converting nil into the Identity filter
          refine ::NilClass do
            ##
            # Convert nil to Identity filter
            def to_filter
              Aws::Templates::Utils::Contextualized::Filter::Identity.new
            end
          end

          ##
          # Proc class patch
          #
          # Adds to_filter method proxying a Proc through Filter interface object
          refine ::Proc do
            ##
            # Proxy the Proc through Proxy filter object
            def to_filter
              Aws::Templates::Utils::Contextualized::Filter::Proxy.new(self)
            end
          end
        end
      end
    end
  end
end
