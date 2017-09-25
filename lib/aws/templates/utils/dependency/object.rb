require 'set'
require 'aws/templates/utils/dependency'

##
# Dependency method stubs
#
# To avoid checking classes directly to filter out dependencies and non-dependencies, we're
# monkey-patching Object class with stubs for Dependency class.
#
# TODO: Devise a better approach and remove the extension
class Object
  EMPTY_SET = Set.new.freeze

  # By default an object is not a dependency
  def dependency?
    false
  end

  # It returns self
  def object
    self
  end

  ##
  # Object root
  #
  # It is used to gracefully process dependencies
  def root; end

  alias not_a_dependency object

  # it returns a set containing a single dependency on itself
  def dependencies
    EMPTY_SET
  end

  # mark the object as dependency
  def as_a_dependency
    Aws::Templates::Utils::Dependency.new(object)
  end

  # mark the object as dependency of itself
  def as_a_self_dependency
    as_a_dependency.to_self
  end
end
