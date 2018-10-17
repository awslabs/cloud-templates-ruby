require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      ##
      # Remember Alan Turing's halting problem and don't believe in miracles. The method will
      # only work with parameters because they are supposed to be pure unmodifying functions.
      # Hence we can terminate if a parameter method was invoked twice in the stack with the same
      # context.
      module Guarded
        Call = Struct.new(:instance, :entity)

        def guarded_for(instance, entity)
          current_call = Call.new(instance, entity)
          return unless trace.add?(current_call)

          ret = yield
          trace.delete(current_call)
          ret
        end

        private

        def trace
          Thread.current[Guarded.name] ||= ::Set.new
        end
      end
    end
  end
end
