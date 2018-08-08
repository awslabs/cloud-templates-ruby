require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module LateBound
        class Link
          attr_reader :selector

          attr_reader :parent

          def origin
            @origin || parent
          end

          def root?
            parent.equal?(origin)
          end

          def path
            location = root? ? "Object(#{parent.object_id.to_s})" : parent.link.path
            "#{location}.#{local_path}"
          end

          def initialize(selector, parent, origin = nil)
            @selector = selector
            @parent = parent
            @origin = origin
          end

          protected

          def local_path
            raise 'Must be overriden'
          end
        end
      end
    end
  end
end
