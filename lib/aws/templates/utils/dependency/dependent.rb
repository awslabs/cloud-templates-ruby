require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Dependency
        ##
        # Dependency node mixin
        #
        # Introduces methods needed to track dependencies of an object. The object needs to
        # implement options method and root method.
        module Dependent
          using Utils::Dependency::Refinements

          ##
          # Introduce dependencies manually
          #
          # Dependencies are calculated from "options" recursive structure by traversal and location
          # of all dependencies automatically. If some dependency is not logical/parametrical but
          # purely chronological, it can be introduced into the dependency list with this method.
          def depends_on(*depends)
            new_dependencies = depends.map { |obj| obj.dependency? ? obj.links : Set[obj] }
                                      .reduce(&:merge)

            new_dependencies.select! { |obj| obj.root == root } unless root.nil?
            dependencies.merge(new_dependencies)
            self
          end
        end
      end
    end
  end
end
