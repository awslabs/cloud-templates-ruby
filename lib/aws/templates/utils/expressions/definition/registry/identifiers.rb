require 'aws/templates/utils'

module Aws
  module Templates
    module Utils
      module Expressions
        class Definition
          class Registry
            ##
            # Identifiers registry
            #
            # Stores identifiers with corresponding invocation adapters.
            class Identifiers < Registry
              ##
              # Invocation adapter
              #
              # When a term is called from expressions, the invocation is going through the adapter
              class Adapter
                ##
                # Variable creation adapter
                #
                # When a variable term is called from expressions, the adapter will create
                # the variable object.
                class Variable < Adapter
                  def invoke(invoker)
                    definition.new(invoker, name)
                  end

                  protected

                  def correct_definition?(definition)
                    definition <= Expressions::Variable
                  end
                end

                ##
                # Macro invocation adapter
                #
                # When a macro term is called from expressions, the adapter will invoke assigned
                # lambda returning result of invocation.
                class Macro < Adapter
                  def initialize(name, &blk)
                    super(name, blk)
                  end

                  def invoke(invoker, *args)
                    invoker.instance_exec(*args, &definition)
                  end

                  protected

                  def correct_definition?(definition)
                    definition.respond_to?(:to_proc)
                  end
                end

                ##
                # Function invocation adapter
                #
                # When a function term is called from expressions, the adapter will create
                # a function object.
                class Function < Adapter
                  ##
                  # Function definition tuple
                  class Tuple
                    attr_reader :name
                    attr_reader :type

                    def initialize(spec)
                      raise "#{spec} is not a hash" unless spec.respond_to?(:to_h)

                      hsh = spec.to_h
                      raise "Definition #{hsh} is incorrect (<name>: <type>)" unless spec.size == 1

                      @type = hsh.values.first
                      raise "#{@type} is not a type" unless @type.is_a?(::Module)

                      @name = hsh.keys.first.to_sym
                    end
                  end

                  def initialize(spec, &blk)
                    func = _transform_to_function_class(spec, &blk)
                    super(func.function_name, func)
                  end

                  def invoke(invoker, *args)
                    definition.new(invoker, *args)
                  end

                  protected

                  def correct_definition?(definition)
                    definition <= Expressions::Function
                  end

                  private

                  def _transform_to_function_class(spec, &blk)
                    return spec if spec.is_a?(::Class)

                    if spec.respond_to?(:to_sym)
                      Expressions::Function.with(spec.to_sym, &blk)
                    elsif spec.respond_to?(:to_hash)
                      _define_function_from_hash(spec, &blk)
                    else
                      raise "#{spec} is not a function definition"
                    end
                  end

                  def _define_function_from_hash(spec, &blk)
                    spec_tuple = Tuple.new(spec)
                    name = spec_tuple.name
                    type = spec_tuple.type

                    return type if type.is_a?(::Class) && name == type.function_name && blk.nil?

                    Expressions::Function.with(name, type, &blk)
                  end
                end

                attr_reader :name
                attr_reader :definition

                def initialize(name, definition)
                  raise_wrong_definition(definition) unless correct_definition?(definition)

                  @definition = definition
                  @name = name.to_sym
                end

                def invoke(_invoker, *_)
                  raise 'Must be overriden'
                end

                protected

                def correct_definition?(_definition)
                  raise 'Must be overriden'
                end

                private

                def raise_wrong_definition(definition)
                  raise "Invalid definition #{definition} for #{self.class}"
                end
              end

              def invoke(name, *args)
                lookup(name).invoke(parent, *args)
              end

              def var(hsh)
                extend!(
                  hsh.map { |name, klass| [name, Adapter::Variable.new(name, klass)] }.to_h
                )
              end

              def func(spec = nil, &blk)
                adapter = Adapter::Function.new(spec, &blk)
                register!(adapter.name, adapter)
              end

              def macro(name, &body)
                register!(name, Adapter::Macro.new(name, &body))
              end

              protected

              def correct_definition?(definition)
                definition.is_a?(Adapter)
              end

              def correct_element?(element)
                element.is_a?(::Symbol)
              end

              def use_defaults
                func range: Expressions::Functions::Range
                func inclusive: Expressions::Functions::Range::Border::Inclusive
                func exclusive: Expressions::Functions::Range::Border::Exclusive
              end
            end
          end
        end
      end
    end
  end
end
