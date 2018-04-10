require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Schemed
        attr_reader :schema

        def initialize(schema)
          obj = unbox_schema(schema)
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

        def check_schema(schema)
          raise 'The method must be overriden'
        end
      end
    end
  end
end
