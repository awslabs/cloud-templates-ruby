require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      ##
      # Functors made easy. Object-oriented way to create Proc-like objects
      module Functor
        def to_proc
          its_me = self

          proc { |*args| its_me.invoke(self, *args) }
        end

        def invoke(_scope, *_args)
          raise 'Must be overriden'
        end
      end
    end
  end
end
