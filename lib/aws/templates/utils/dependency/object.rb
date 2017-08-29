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
  # By default an object is not a dependency
  def dependency?
    false
  end

  EMPTY_SET = Set.new.freeze

  # It returns self
  def object
    self
  end

  alias not_a_dependency object

  # it returns empty list of dependencies
  def dependencies
    EMPTY_SET
  end

  # mark the object as dependency
  def as_dependency
    dependency? ? self : Aws::Templates::Utils::Dependency.new(self)
  end
end
