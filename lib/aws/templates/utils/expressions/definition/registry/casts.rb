require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Expressions
        class Definition
          class Registry
            ##
            # Type casts registry
            #
            # Stores type cast lambdas and invokes them on-demand for objects.
            class Casts < Registry
              using Expressions::Refinements
              using Utils::Dependency::Refinements

              def invoke(obj)
                result = obj

                unless result.boxed_expression?
                  target_mod = obj.class.ancestors.find { |mod| present?(mod) }

                  return obj if target_mod.nil?

                  result = parent.instance_exec(obj, &lookup(target_mod))
                end

                raise "Casting is not an expression #{result}" unless result.boxed_expression?

                result.scope = parent
                result
              end

              def define(type, &cast)
                register!(type, cast)
              end

              protected

              def correct_definition?(definition)
                definition.respond_to?(:to_proc)
              end

              def correct_element?(element)
                element.is_a?(::Module)
              end

              DEFAULTS = {
                ::String => proc do |obj|
                  str_copy = obj.dup

                  class <<str_copy
                    include Expressions::Expression
                  end

                  str_copy.scope = self

                  str_copy
                end,

                ::Numeric => proc { |num| Expressions::Number.new(self, num) },

                Utils::Dependency::Wrapper => proc do |wrapper|
                  cast_for(wrapper.object).as_a_dependency.to(wrapper)
                end,

                ::TrueClass => proc { |v| Expressions::Boolean.new(self, v) },

                ::FalseClass => proc { |v| Expressions::Boolean.new(self, v) },

                ::Range => proc do |v|
                  Expressions::Range.new(
                    self,
                    Expressions::Range::Inclusive.new(self, v.min),
                    (
                      v.exclude_end? ? Expressions::Range::Exclusive : Expressions::Range::Inclusive
                    ).new(self, v.last)
                  )
                end
              }.freeze

              def use_defaults
                DEFAULTS.each_pair { |type, cast_proc| register!(type, cast_proc) }
              end
            end
          end
        end
      end
    end
  end
end
