require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module LateBound
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
