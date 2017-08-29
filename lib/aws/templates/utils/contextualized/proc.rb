require 'aws/templates/utils/contextualized'

##
# Proc class patch
#
# Adds to_filter method proxying a Proc through Filter interface object
class Proc
  ##
  # Proxy the Proc through Proxy filter object
  def to_filter
    Aws::Templates::Utils::Contextualized::Filter::Proxy.new(self)
  end
end
