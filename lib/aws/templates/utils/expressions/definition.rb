require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Expressions
        ##
        # DSL definition
        #
        # It's a container for function and variable definitions which are allowed in a particular
        # instance. It's also a factory for Variable and Function instances. The factory method
        # is invoked by either DSL module or Parser.
        class Definition
          attr_reader :identifiers
          attr_reader :casts
          attr_reader :context

          def cast(type, &blk)
            casts.define(type, &blk)
          end

          def var(hsh)
            identifiers.var(hsh)
          end

          def func(spec = nil, &blk)
            identifiers.func(spec, &blk)
          end

          def macro(name, &body)
            identifiers.macro(name, &body)
          end

          def instantiate(name, *args)
            cast_for(_instantiate(name, args))
          end

          def cast_for(obj)
            casts.invoke(obj)
          end

          def present?(name)
            identifiers.present?(name) || in_context?(name)
          end

          def in_context?(name)
            context.respond_to?(name)
          end

          def initialize(identifiers: nil, context: nil, casts: nil, &blk)
            @identifiers = Definition::Registry::Identifiers.new(self, identifiers)
            @casts = Definition::Registry::Casts.new(self, casts)
            @context = context

            instance_exec(context, &blk) if block_given?
          end

          def extend(spec = {}, &blk)
            self.class
                .new(identifiers: identifiers, context: context, casts: casts)
                .extend!(spec, &blk)
          end

          def extend!(identifiers: nil, context: nil, casts: nil, &blk)
            @context = context if context

            @identifiers.extend!(identifiers)
            @casts.extend!(casts)

            instance_exec(context, &blk) if block_given?

            self
          end

          def dsl(&blk)
            @dsl ||= Expressions::Dsl.new(self)
            @dsl.expression(&blk)
          end

          private

          def _instantiate(name, args)
            return identifiers.invoke(name, *args) if identifiers.present?(name)
            return context.send(name, *args) if in_context?(name)

            raise "#{name} is not defined"
          end
        end
      end
    end
  end
end
