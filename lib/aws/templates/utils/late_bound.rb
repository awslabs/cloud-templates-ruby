require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module LateBound
        def self.build_from(link)
          Builder.new(link)
        end

        def self.as_method(name, parent, origin = nil)
          MethodLink.new(name, parent, origin)
        end
      end
    end
  end
end
