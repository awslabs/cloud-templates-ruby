require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module LateBound
        ##
        # Late bound value's link
        #
        # Links are special objects which contain late bound value's binding information.
        # Effectively they are links to the point of origin for late bound value.
        class Link
          # Class-specific selector for value
          attr_reader :selector

          # Parent object (can be a late bound value or the origin)
          attr_reader :parent

          # User-defined data
          attr_reader :meta

          def origin
            @origin || parent
          end

          def root?
            parent.equal?(origin)
          end

          # Absolute path of the value to the point of origin
          def path
            location = root? ? "Object(#{parent.object_id})" : parent.link.path
            "#{location}.#{local_path}"
          end

          def initialize(selector, parent, origin = nil, meta = nil)
            @selector = selector
            @parent = parent
            @origin = origin
            @meta = meta
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
