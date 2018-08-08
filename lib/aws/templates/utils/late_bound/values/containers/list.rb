require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module LateBound
        module Values
          module Containers
            class List < Container
              class Index < LateBound::Link
                alias index selector

                protected

                def local_path
                  "index(#{index.inspect})"
                end
              end

              INDEX_CONCEPT = Utils::Parametrized::Concept.from {
                {
                  constraint: not_nil,
                  transform: as_integer
                }
              }

              def key_concept
                INDEX_CONCEPT
              end

              attr_reader :value_concept

              def initialize(*args)
                super
                @value_concept = concept_for(transform.sub_parameter)
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
