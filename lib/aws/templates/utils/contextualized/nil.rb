require 'aws/templates/utils/contextualized'

##
# NilClass class patch
#
# Adds to_filter method converting nil into the Identity filter
class NilClass
  ##
  # Convert nil to Identity filter
  def to_filter
    Aws::Templates::Utils::Contextualized::Filter::Identity.new
  end
end
