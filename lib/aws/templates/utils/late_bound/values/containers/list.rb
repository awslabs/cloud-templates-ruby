require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module LateBound
        module Values
          module Containers
            ##
            # Late-bound list
            #
            # The container supports index operator which can be supplied with either concrete index
            # value or late-bound one and produces typed late-bound "element" value with the link
            # set to point to the list as a parent.
            class List < Container
              # List index link class
              class Index < LateBound::Link
                alias index selector

                protected

                def local_path
                  "index(#{index.inspect})"
                end
              end

              INDEX_CONCEPT = Utils::Parametrized::Concept.from do
                {
                  constraint: not_nil,
                  transform: as_integer
                }
              end

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
