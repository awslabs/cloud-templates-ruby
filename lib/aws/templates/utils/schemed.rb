require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      ##
      # Process definitions expressed as hash schemes
      #
      # Auxiliary module which provides standard checker for initializer if schema is correct and
      # also unboxes the schema. "Schema" here is combination of lambda object calculation which
      # needs to be postponed and hashes. It's auxiliary utility to de-duplicate code from such
      # classes as constraint Has and constraint DependsOnValue which both can be defined through
      # such kind of schemes.
      module Schemed
        attr_reader :schema

        def initialize(*schema)
          raise ArgumentError.new('At least single arguments required') if schema.empty?

          obj = unbox_schema(schema.size == 1 ? schema.first : schema)
          check_schema(obj)
          @schema = obj
        end

        def unbox_schema(schema)
          return { schema => nil } if schema.respond_to?(:to_sym)
          return schema.to_hash if schema.respond_to?(:to_hash)
          return schema.to_proc.call(self) if schema.respond_to?(:to_proc)

          if schema.respond_to?(:to_a)
            return schema.to_a.each_with_object({}) { |field, hsh| hsh[field] = nil }
          end

          { schema => nil }
        end

        def check_schema(_schema)
          raise 'The method must be overriden'
        end
      end
    end
  end
end
