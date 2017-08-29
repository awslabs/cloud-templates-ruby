require 'aws/templates/utils/contextualized'

##
# Hash class patch
#
# Adds to_filter method converting a hash into an Override filter
class Hash
  ##
  # Convert to Override filter
  def to_filter
    Aws::Templates::Utils::Contextualized::Filter::Override.new(self)
  end
end
