require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Contextualized
        class Filter
          ##
          # Statically scoped filter
          #
          # Scoped filter wraps whatever Proc obejct passed to it into specified scope for
          # execution. So whatever the scope the filter is called in, it will always be evaluated
          # in the same scope specified at creation.
          #
          # The filter is used by the internal mechanics of the framework.
          class Scoped < self
            using Contextualized::Refinements

            attr_reader :scoped_filter
            attr_reader :scope

            def initialize(fltr, scp)
              @scoped_filter = _check_filter(fltr)
              @scope = scp
            end

            def filter(options, memo, _)
              scope.instance_exec(options, memo, &scoped_filter)
            end

            private

            def _check_filter(fltr)
              raise "#{fltr} is not a filter" unless fltr.respond_to?(:to_proc)

              fltr
            end
          end
        end
      end
    end
  end
end
