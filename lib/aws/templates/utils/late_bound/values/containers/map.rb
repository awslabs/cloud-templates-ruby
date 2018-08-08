require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module LateBound
        module Values
          module Containers
            class Map < Container
              class Index < LateBound::Link
                alias key selector

                protected

                def local_path
                  "key(#{key.inspect})"
                end
              end

              attr_reader :key_concept
              attr_reader :value_concept

              def initialize(*args)
                super
                definition = transform.definition
                @key_concept = concept_for(definition.key_parameter)
                @value_concept = concept_for(definition.value_parameter)
              end

              protected

              def link_for(key)
                Index.new(key, self, link.origin)
              end
            end
          end
        end
      end
    end
  end
end
