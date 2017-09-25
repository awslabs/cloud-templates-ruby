require 'set'

module Aws
  module Templates
    module Utils
      module Parametrized
        ##
        # Map from "parametrized" to "recursive"
        #
        # The class is adapter used to wrap any "parametrized" object (implementing "parametrized"
        # concept) into an object implementing "hashable" and "recursive" concepts.
        class Mapper
          attr_reader :delegate

          SPECIAL_CASE = [:root].freeze

          def [](key)
            @delegate.public_send(key) if @parameter_names.include?(key)
          end

          def include?(key)
            @parameter_names.include?(key)
          end

          def to_hash
            @parameter_names.each_with_object({}) do |method_name, hsh|
              hsh[method_name] = @delegate.public_send(method_name)
            end
          end

          def keys
            @parameter_names.to_a
          end

          def dependency?
            delegate.dependency?
          end

          def dependencies
            delegate.dependencies
          end

          def object
            delegate.object
          end

          def initialize(obj)
            obj.parameter_names.each { |pname| _check_parameter(obj, pname) }
            @delegate = obj
            @parameter_names = Set.new(@delegate.parameter_names).merge(SPECIAL_CASE)
          end

          private

          PROPERTY_LIKE = /^[^_!?][^!?]*$/

          def _check_parameter(obj, name)
            _raise_misnamed(obj, name) unless name.to_s =~ PROPERTY_LIKE
            _raise_arity(obj, name) unless obj.public_method(name).arity.zero?
          end

          def _raise_misnamed(obj, name)
            raise "Parameter #{name} of #{obj} is mis-named"
          end

          def _raise_arity(obj, name)
            raise "Parameter #{name} of #{obj} has arity"
          end
        end
      end
    end
  end
end
