require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      class Dependency
        ##
        # Refinements for transparent dependecy handling
        #
        # Dependency mechanism requres transparent language support to work correctly with
        # arbitrary objects and object collections. This refinement introduces methods used
        # for dependency processing.
        module Refinements
          EMPTY_SET = ::Set.new.freeze

          ##
          # Dependency method stubs
          #
          # To avoid checking classes directly to filter out dependencies and non-dependencies,
          # we're monkey-patching Object class with stubs for Dependency class.
          refine ::BasicObject do
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

            alias_method :not_a_dependency, :object

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
        end
      end
    end
  end
end

##
# Methods to be added to all collections
#
# NOTICE: We are not using refinements for it because of Ruby 2.3 support. This version doesn't
#         support mixin-level refinements.
module Enumerable
  using Aws::Templates::Utils::Dependency::Refinements

  def dependencies
    # rubocop:disable Style/SymbolProc
    # Refinements don't support dynamic dispatch yet. So, symbolic methods don't work
    find_all { |obj| obj.dependency? }
      .inject(::Set.new) { |acc, elem| acc.merge(elem.dependencies) }
    # rubocop:enable Style/SymbolProc
  end

  def dependency?
    true
  end
end
