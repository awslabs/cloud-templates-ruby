require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module LateBound
        module Values
          module Containers
            ##
            # Generic late-bound container
            #
            # It defines index operator and common utilities for late-bound value containers
            # (late-bound values which are containers). Also, it defines a few reverse-of-control
            # methods to be overriden by concrete implementations
            class Container < Values::Value
              attr_reader :instance
              attr_reader :constraint
              attr_reader :transform

              def key_concept
                raise 'Must be overriden'
              end

              def value_concept
                raise 'Must be overriden'
              end

              def self.for(link, instance, transform, constraint)
                new(link, instance, transform, constraint)
              end

              def initialize(link, instance, transform, constraint)
                super(link, constraint)
                @instance = instance
                @transform = transform
              end

              ##
              # Index operator
              #
              # Returns late bound value by key
              def [](key)
                _value_reference_for(_process_key(key))
              end

              def transform_as(other_transform, instance)
                return self if transform.processable_by?(other_transform)

                raise Templates::Exception::ParameterLateBoundException.new(
                  other_transform,
                  instance,
                  self,
                  "Late bound (#{transform}) is not processable by the target transform"
                )
              end

              protected

              def link_for(_key)
                raise 'Must be overriden'
              end

              def concept_for(parameter)
                parameter && parameter.concept
              end

              private

              def _process_key(key)
                return key if key_concept.nil?

                instance.instance_exec(key, &key_concept)
              end

              def _value_reference_for(key)
                return Values::Empty.new(link_for(key)) if value_concept.nil?

                instance.instance_exec(LateBound.build_from(link_for(key)), &value_concept)
              end
            end
          end
        end
      end
    end
  end
end
