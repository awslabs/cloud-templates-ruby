require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module LateBound
        module Values
          class Structure < Value
            attr_reader :klass

            ##
            # Makes the late bound accessible as recursive concept
            class RecursiveAdapter
              attr_reader :target

              ##
              # Defined hash keys
              def keys
                target.parameter_names
              end

              ##
              # Index operator
              #
              # Returns late bound field by name
              def [](key)
                return unless include?(key)
                target.send(key)
              end

              ##
              # If key is present
              def include?(key)
                target.respond_to?(key)
              end

              def initialize(target)
                @target = target
              end
            end

            def self.for(link, _instance, transform, constraint)
              new(link, transform.klass, constraint)
            end

            def initialize(link, klass, constraint)
              super(link, constraint)
              @klass = klass
            end

            def method_missing(name, *args, &block)
              super unless respond_to_missing?(name)
              _get_late_bound_for(name)
            end

            def respond_to_missing?(name, include_private = false)
              parameter_names.include?(name)
            end

            def transform_as(transform, instance)
              return self if transform.nil?
              transform.transform_wrapper(self, instance)
            end

            def parameter_names
              @parameter_names ||= klass.list_all_parameter_names
            end

            def to_recursive
              RecursiveAdapter.new(self)
            end

            def initialize(link, klass, constraint)
              super(link, constraint)
              @klass = klass
            end

            private

            def _get_late_bound_for(name)
              raise "No parameter #{name}" unless parameter_names.include?(name)

              concept = klass.get_parameter(name).concept

              child_link = MethodLink.new(name, self, link.origin)

              return Empty.new(child_link) if concept.nil?

              instance_exec(LateBound.build_from(child_link), &concept)
            end
          end
        end
      end
    end
  end
end
