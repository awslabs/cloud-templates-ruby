require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Contextualized
        class Filter
          ##
          # Base class for recursive operations
          #
          # Internally used by Add and Remove filters.
          class RecursiveSchemaFilter < self
            using Contextualized::Refinements

            attr_reader :scheme

            def initialize(*args)
              schm = if args.last.respond_to?(:to_hash)
                args.each_with_object(args.pop) do |field, hsh|
                  hsh[field] = nil
                  hsh
                end
              else
                args
              end

              @scheme = _check_scheme(schm)
            end

            private

            def _check_scheme(schm)
              if schm.respond_to?(:to_hash)
                schm.to_hash.each_pair { |_, sub| _check_scheme(sub) unless sub.nil? }
              elsif !schm.respond_to?(:to_a)
                raise "#{schm.inspect} is not appropriate branch in the scheme"
              end

              schm
            end
          end
        end
      end
    end
  end
end
