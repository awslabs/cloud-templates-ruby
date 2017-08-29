require 'set'

##
# Dependencies methods definitions for all collections
module Enumerable
  def dependencies
    find_all(&:dependency?).inject(Set.new) { |acc, elem| acc.merge(elem.dependencies) }
  end

  def dependency?
    true
  end
end
