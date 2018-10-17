require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module LateBound
        ##
        # Method link
        #
        # Method links differ from other links in that they contain method/field name as their
        # selector. Immediate late-bound values of artifacts will always be linked by method links.
        class MethodLink < Link
          alias name selector

          protected

          def local_path
            "method(#{name.inspect})"
          end
        end
      end
    end
  end
end
