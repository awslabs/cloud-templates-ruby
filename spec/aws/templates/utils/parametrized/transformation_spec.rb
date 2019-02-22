require 'spec_helper'
require 'aws/templates/utils/parametrized'
require 'aws/templates/rendering/render'
require 'polyglot'
require 'treetop'
require 'test_grammar'

class TestRender < Aws::Templates::Rendering::Render
  StringView = Class.new(Aws::Templates::Rendering::BasicView) do
    def to_processed
      _stringify(instance)
    end

    def _stringify(obj)
      return obj.to_s unless obj.respond_to?(:to_hash)

      obj.to_hash.map { |k, v| [_stringify(k), _stringify(v)] }.to_h
    end
  end

  StringView.register_in self
  StringView.artifact ::Object
end

describe Aws::Templates::Utils::Parametrized::Transformation do
  let(:parametrized_class) do
    Class.new do
      include Aws::Templates::Utils::Parametrized

      def self.getter
        as_is
      end

      attr_reader :options

      def initialize(options)
        @options = options
      end
    end
  end

  describe 'as_object' do
    let(:test_class) do
      Class.new(parametrized_class) do
        parameter :something,
                  transform: as_object {
                    parameter :a, description: 'Parameter A'
                    parameter :b, description: 'Parameter B'
                    parameter :c, description: 'Parameter C', constraint: not_nil
                  }
      end
    end

    it 'transforms hash into object correctly' do
      i = test_class.new(something: { a: 1, b: 2, c: 3 })
      expect([i.something.a, i.something.b, i.something.c])
        .to be == [1, 2, 3]
    end

    it 'allows nil values in sub-fields if no constraint is specified' do
      i = test_class.new(something: { a: 1, b: nil, c: 3 })
      expect([i.something.a, i.something.b, i.something.c])
        .to be == [1, nil, 3]
    end

    it 'throws an error if sub-parameter constraint is not satisfied' do
      i = test_class.new(something: { a: 1, b: 2, c: nil })
      expect { [i.something.a, i.something.b, i.something.c] }
        .to raise_error Aws::Templates::Exception::ParameterProcessingException
    end
  end

  describe 'as_list' do
    let(:test_class) do
      Class.new(parametrized_class) do
        parameter :something,
                  description: 'Something misterious',
                  transform: as_list(
                    name: :element,
                    description: 'Force of nature'
                  )
        parameter :something_else,
                  description: 'Absolutely incomprehensible',
                  transform: as_list(
                    name: :element,
                    description: 'Celestial image',
                    constraint: not_nil
                  )
        parameter :something_without_duplicates,
                  description: 'Absolutely incomprehensible',
                  transform: as_list(
                    name: :element,
                    description: 'Celestial image',
                    concept: Aws::Templates::Utils::Parametrized::Concept.from do
                      { constraint: not_nil }
                    end,
                    unique: true
                  )
      end
    end

    it 'handles nil values' do
      expect(test_class.new({}).something).to be_nil
    end

    it 'handles list value' do
      expect(test_class.new(something: [1, 2, 3]).something).to be == [1, 2, 3]
    end

    it 'allows nil values if no constraints are specified' do
      expect(test_class.new(something: [1, nil, 3]).something).to be == [1, nil, 3]
    end

    it 'works with any kind of object' do
      expect(test_class.new(something: 'abc'.each_char).something).to be == %w[a b c]
    end

    it 'fails if the value can not be transformed to an array' do
      expect { test_class.new(something: 'abc').something }
        .to raise_error Aws::Templates::Exception::ParameterProcessingException
    end

    it 'returns correct value if sub-constraints are satisfied' do
      expect(test_class.new(something_else: [1, 2, 3]).something_else).to be == [1, 2, 3]
    end

    context 'when uniqueness is required' do
      it 'works if elements are unique' do
        expect(test_class.new(something_without_duplicates: [1, 2, 3]).something_without_duplicates)
          .to be == [1, 2, 3]
      end

      it 'fails if there are duplicates' do
        expect do
          test_class.new(something_without_duplicates: [1, 1, 3]).something_without_duplicates
        end.to raise_error Aws::Templates::Exception::ParameterProcessingException
      end
    end

    context 'when one or more elements don\'t satisfy sub-constraint' do
      let(:exception) do
        begin
          test_class.new(something_else: [1, nil, 3]).something_else
        rescue StandardError => e
          e
        end
      end

      it 'fails' do
        expect { test_class.new(something_else: [1, nil, 3]).something_else }.to raise_error(
          Aws::Templates::Exception::ParameterProcessingException,
          /something_else/
        )
      end

      it 'fails transform exception' do
        expect(exception.cause).to be_a Aws::Templates::Exception::ParameterTransformException
      end

      it 'fails nested parameter exception' do
        expect(exception.cause.cause)
          .to be_a Aws::Templates::Exception::ParameterProcessingException
      end

      it 'fails with correct message' do
        expect(exception.cause.cause.message).to match(/Celestial image/)
      end
    end

    describe 'analytical comparison' do
      let(:stricter_transform) { test_class.get_parameter(:something_else).concept.transform }
      let(:loosened_transform) { test_class.get_parameter(:something).concept.transform }
      let(:nonunique_transform) { test_class.get_parameter(:something_else).concept.transform }
      let(:unique_transform) do
        test_class.get_parameter(:something_without_duplicates).concept.transform
      end

      it 'satisfies loosened constraint' do
        expect(stricter_transform).to be_processable_by loosened_transform
      end

      it 'doesn\'t satisfies stricter constraint' do
        expect(loosened_transform).not_to be_processable_by stricter_transform
      end

      it 'allows unique list where uniquiness not required' do
        expect(unique_transform).to be_processable_by nonunique_transform
      end

      it 'is not compatible with non-unique list where uniquiness is required' do
        expect(nonunique_transform).not_to be_processable_by unique_transform
      end
    end
  end

  describe 'as_rendered' do
    let(:render_class) { TestRender }

    let(:test_class) do
      klass = Class.new(parametrized_class)
      klass.parameter :something, transform: klass.as_rendered(render_class)
      klass
    end

    it 'transforms hash into stringified hash correctly' do
      i = test_class.new(something: { a: 1, b: 2, c: 3 })
      expect(i.something).to be == { 'a' => '1', 'b' => '2', 'c' => '3' }
    end

    it 'allows nil value' do
      i = test_class.new({})
      expect(i.something).to be_nil
    end
  end

  describe 'as_parsed' do
    let(:parser) { TestGrammarParser }

    let(:test_class) do
      klass = Class.new(parametrized_class)
      klass.parameter :something, transform: klass.as_parsed(parser)
      klass
    end

    it 'parses expression' do
      i = test_class.new(something: '1 + 1')
      expect(i.something.value).to be == 2
    end

    it 'does not parse nil' do
      i = test_class.new({})
      expect(i.something).to be_nil
    end

    context 'with syntax error' do
      let(:exception) do
        begin
          test_class.new(something: '1a').something
        rescue StandardError => e
          e
        end
      end

      it 'fails' do
        expect { test_class.new(something: '1a').something }.to raise_error(
          Aws::Templates::Exception::ParameterProcessingException,
          /something/
        )
      end

      it 'fails transform exception' do
        expect(exception.cause).to be_a Aws::Templates::Exception::ParameterTransformException
      end

      it 'fails with correct message' do
        expect(exception.cause.cause.message).to match(/Expected one of/)
      end
    end
  end

  describe 'as_integer' do
    let(:test_class) do
      Class.new(parametrized_class) do
        parameter :something, transform: as_integer
      end
    end

    it 'transforms string into integer correctly' do
      i = test_class.new(something: '23')
      expect(i.something).to be == 23
    end

    it 'allows nil value' do
      i = test_class.new({})
      expect(i.something).to be_nil
    end

    it 'fails on wrong value' do
      i = test_class.new(something: [])
      expect { i.something }.to raise_error Aws::Templates::Exception::ParameterProcessingException
    end

    describe 'analytical comparison' do
      let(:transform) { parametrized_class.as_integer }

      it 'can be processed by itself' do
        expect(transform).to be_processable_by parametrized_class.as_integer
      end

      it 'can\'t be processed by arbitrary transform' do
        expect(transform).not_to be_processable_by parametrized_class.as_boolean
      end
    end
  end

  describe 'as_float' do
    let(:test_class) do
      Class.new(parametrized_class) do
        parameter :something, transform: as_float
      end
    end

    it 'transforms string into float correctly' do
      i = test_class.new(something: '23.0')
      expect(i.something).to be == 23.0
    end

    it 'allows nil value' do
      i = test_class.new({})
      expect(i.something).to be_nil
    end

    it 'fails on wrong value' do
      i = test_class.new(something: [])
      expect { i.something }.to raise_error Aws::Templates::Exception::ParameterProcessingException
    end

    describe 'analytical comparison' do
      let(:transform) { parametrized_class.as_float }

      it 'can be processed by itself' do
        expect(transform).to be_processable_by parametrized_class.as_float
      end

      it 'can\'t be processed by arbitrary transform' do
        expect(transform).not_to be_processable_by parametrized_class.as_boolean
      end
    end
  end

  describe 'as_string' do
    let(:test_class) do
      Class.new(parametrized_class) do
        parameter :something, transform: as_string
      end
    end

    it 'transforms integer into string correctly' do
      i = test_class.new(something: 23)
      expect(i.something).to be == '23'
    end

    it 'allows nil value' do
      i = test_class.new({})
      expect(i.something).to be_nil
    end

    describe 'analytical comparison' do
      let(:transform) { parametrized_class.as_string }

      it 'can be processed by itself' do
        expect(transform).to be_processable_by parametrized_class.as_string
      end

      it 'can\'t be processed by arbitrary transform' do
        expect(transform).not_to be_processable_by parametrized_class.as_boolean
      end
    end
  end

  describe 'as_boolean' do
    let(:test_class) do
      Class.new(parametrized_class) do
        parameter :something, transform: as_boolean
      end
    end

    it 'transforms string into boolean correctly' do
      i = test_class.new(something: 23)
      expect(i.something).to be == true
    end

    it 'transforms false correctly' do
      i = test_class.new(something: false)
      expect(i.something).to be == false
    end

    it 'transforms true correctly' do
      i = test_class.new(something: true)
      expect(i.something).to be == true
    end

    it 'transforms false string correctly' do
      i = test_class.new(something: 'false')
      expect(i.something).to be == false
    end

    it 'allows nil value' do
      i = test_class.new({})
      expect(i.something).to be_nil
    end

    describe 'analytical comparison' do
      let(:transform) { parametrized_class.as_boolean }

      it 'can be processed by itself' do
        expect(transform).to be_processable_by parametrized_class.as_boolean
      end

      it 'can\'t be processed by arbitrary transform' do
        expect(transform).not_to be_processable_by parametrized_class.as_string
      end
    end
  end

  describe 'as_hash' do
    let(:test_class) do
      Class.new(parametrized_class) do
        parameter :something, transform: as_hash
        parameter :something2,
                  transform: as_hash {
                    key name: :key,
                        description: 'String key',
                        constraint: not_nil,
                        transform: as_string
                    value name: :number,
                          description: 'Just a number',
                          constraint: not_nil,
                          transform: as_integer
                  }
      end
    end

    let(:hashable) do
      Class.new do
        def to_hash
          { w: 'qwe' }
        end
      end
    end

    it 'transforms hash correctly' do
      i = test_class.new(something: { q: 3 })
      expect(i.something).to be == { q: 3 }
    end

    it 'transforms array into hash correctly' do
      i = test_class.new(something: [[:q, 3]])
      expect(i.something).to be == { q: 3 }
    end

    it 'transforms an object into hash correctly' do
      i = test_class.new(something: hashable.new)
      expect(i.something).to be == { w: 'qwe' }
    end

    it 'allows nil value' do
      i = test_class.new({})
      expect(i.something).to be_nil
    end

    it 'understands internal structure' do
      i = test_class.new(something2: { q: '3' })
      expect(i.something2).to be == { 'q' => 3 }
    end

    context 'with internal constraint violated' do
      let(:exception) do
        begin
          test_class.new(something2: { q: nil }).something2
        rescue StandardError => e
          e
        end
      end

      it 'fails' do
        expect { test_class.new(something2: { q: nil }).something2 }.to raise_error(
          Aws::Templates::Exception::ParameterProcessingException,
          /something/
        )
      end

      it 'fails transform exception' do
        expect(exception.cause).to be_a Aws::Templates::Exception::ParameterTransformException
      end

      it 'fails nested parameter exception' do
        expect(exception.cause.cause)
          .to be_a Aws::Templates::Exception::ParameterProcessingException
      end

      it 'fails with correct message' do
        expect(exception.cause.cause.message).to match(/Just a number/)
      end
    end

    describe 'analytical comparison' do
      context 'when unrestricted' do
        let(:transform) { parametrized_class.as_hash }

        it 'is processable by itself' do
          expect(parametrized_class.as_hash).to be_processable_by transform
        end

        context 'with restricted target' do
          let(:key_concept) { {} }
          let(:value_concept) { {} }

          let(:target_transform) do
            kconcept = key_concept
            vconcept = value_concept

            parametrized_class.as_hash do
              key kconcept
              value vconcept
            end
          end

          context 'with key concept is defined' do
            let(:key_concept) do
              { transform: parametrized_class.as_integer }
            end

            it 'can process' do
              expect(target_transform).to be_processable_by transform
            end

            it 'can\'t be processed by' do
              expect(transform).not_to be_processable_by target_transform
            end

            context 'with value concept defined' do
              let(:value_concept) do
                { transform: parametrized_class.as_integer }
              end

              it 'can process' do
                expect(target_transform).to be_processable_by transform
              end

              it 'can\'t be processed by' do
                expect(transform).not_to be_processable_by target_transform
              end
            end
          end
        end
      end

      context 'when key and value are restricted by constraints' do
        let(:description) do
          proc do
            key name: :key,
                description: 'String key',
                constraint: not_nil,
                transform: as_string
            value name: :number,
                  description: 'Just a number',
                  constraint: not_nil,
                  transform: as_integer
          end
        end

        let(:transform) { parametrized_class.as_hash(&description) }

        it 'is processable by itself' do
          expect(parametrized_class.as_hash(&description)).to be_processable_by transform
        end

        context 'with unrestricted target' do
          it 'passes' do
            expect(transform).to be_processable_by parametrized_class.as_hash
          end
        end

        context 'with restricted target' do
          let(:key_concept) { {} }
          let(:value_concept) { {} }

          let(:target_transform) do
            kconcept = key_concept
            vconcept = value_concept

            parametrized_class.as_hash do
              key kconcept
              value vconcept
            end
          end

          context 'when key concept is defined' do
            context 'when the concept is compatible with the original' do
              let(:key_concept) do
                { transform: parametrized_class.as_string }
              end

              it 'can be processed by' do
                expect(transform).to be_processable_by target_transform
              end

              it 'can\'t process' do
                expect(target_transform).not_to be_processable_by transform
              end

              context 'with value concept defined' do
                context 'when the concept is compatible with the original' do
                  let(:value_concept) do
                    { transform: parametrized_class.as_integer }
                  end

                  it 'can\'t process' do
                    expect(target_transform).not_to be_processable_by transform
                  end

                  it 'can be processed by' do
                    expect(transform).to be_processable_by target_transform
                  end
                end

                context 'when the concept is incompatible with the original' do
                  let(:value_concept) do
                    { transform: parametrized_class.as_float }
                  end

                  it 'can\'t process' do
                    expect(target_transform).not_to be_processable_by transform
                  end

                  it 'can\'t be processed by' do
                    expect(transform).not_to be_processable_by target_transform
                  end
                end
              end
            end

            context 'when the concept is incompatible with the original' do
              let(:key_concept) do
                { transform: parametrized_class.as_float }
              end

              it 'can\'t be processed by' do
                expect(transform).not_to be_processable_by target_transform
              end

              it 'can\'t process' do
                expect(target_transform).not_to be_processable_by transform
              end
            end
          end
        end
      end
    end
  end

  describe 'as_json' do
    let(:test_class) do
      Class.new(parametrized_class) do
        parameter :something, transform: as_json
      end
    end

    it 'passes nil as is' do
      i = test_class.new(something: nil)
      expect(i.something).to be_nil
    end

    it 'returns hash if simple hash is passed' do
      i = test_class.new(something: { q: 1 })
      expect(i.something).to be == { 'q' => 1 }
    end

    it 'parses string' do
      i = test_class.new(something: '{"q":1}')
      expect(i.something).to be == { 'q' => 1 }
    end

    describe 'analytical comparison' do
      let(:transform) { parametrized_class.as_json }

      it 'can be processed by itself' do
        expect(transform).to be_processable_by parametrized_class.as_json
      end

      it 'can\'t be processed by arbitrary transform' do
        expect(transform).not_to be_processable_by parametrized_class.as_string
      end
    end
  end

  describe 'as_timestamp' do
    let(:test_class) do
      Class.new(parametrized_class) do
        parameter :something, transform: as_timestamp
      end
    end

    it 'passes nil as is' do
      i = test_class.new(something: nil)
      expect(i.something).to be_nil
    end

    it 'looks up class name' do
      i = test_class.new(something: '2018-05-01T10:00:00Z')
      expect(i.something.to_s).to be == '2018-05-01 10:00:00 UTC'
    end

    describe 'analytical comparison' do
      let(:transform) { parametrized_class.as_timestamp }

      it 'can be processed by itself' do
        expect(transform).to be_processable_by parametrized_class.as_timestamp
      end

      it 'can\'t be processed by arbitrary transform' do
        expect(transform).not_to be_processable_by parametrized_class.as_string
      end
    end
  end

  describe 'as_module' do
    let(:test_class) do
      Class.new(parametrized_class) do
        parameter :something, transform: as_module
      end
    end

    it 'passes a class as is' do
      i = test_class.new(something: Object)
      expect(i.something).to be == Object
    end

    it 'looks up class name' do
      i = test_class.new(something: 'Object')
      expect(i.something).to be == Object
    end

    it 'is able to work with paths' do
      i = test_class.new(something: 'Object::Object::Object::Array')
      expect(i.something).to be == Array
    end

    it 'accepts different path specifications' do
      i = test_class.new(something: 'Object/Object/Object/Array')
      expect(i.something).to be == Array
    end

    describe 'analytical comparison' do
      let(:transform) { parametrized_class.as_module }

      it 'can be processed by itself' do
        expect(transform).to be_processable_by parametrized_class.as_module
      end

      it 'can\'t be processed by arbitrary transform' do
        expect(transform).not_to be_processable_by parametrized_class.as_string
      end
    end
  end

  describe 'as_chain' do
    let(:test_class) do
      Class.new(parametrized_class) do
        parameter :something,
                  transform: as_chain(as_hash, as_object { parameter :rule })
      end
    end

    it 'applies all transformations' do
      i = test_class.new(something: [[:rule, 1]])
      expect(i.something.rule).to be == 1
    end

    describe 'analytical comparison' do
      let(:transform) do
        parametrized_class.instance_eval do
          as_chain(as_float, as_integer, as_string)
        end
      end

      let(:another_transform) do
        parametrized_class.instance_eval do
          as_chain(as_string, as_integer, as_boolean)
        end
      end

      it 'can be processed by a chain with input-output compatibility' do
        expect(transform).to be_processable_by another_transform
      end

      it 'can process input type' do
        expect(parametrized_class.as_float).to be_processable_by transform
      end

      it 'can be processed as output type' do
        expect(transform).to be_processable_by parametrized_class.as_string
      end

      it 'can\'t be processed as intermediate type' do
        expect(parametrized_class.as_integer).not_to be_processable_by transform
      end

      it 'can\'t process intermediate type' do
        expect(transform).not_to be_processable_by parametrized_class.as_integer
      end
    end
  end

  describe 'as_expression' do
    context 'without context-dependent block' do
      let(:test_class) do
        Class.new(parametrized_class) do
          include Aws::Templates::Utils::Expressions::Mixin

          definition = Aws::Templates::Utils::Expressions::Definition.new do
            variables x: Aws::Templates::Utils::Expressions::Variables::Arithmetic
          end

          parameter :something,
                    transform: as_expression(definition)
        end
      end

      it 'works with boxable expressions' do
        i = test_class.new(something: 1)
        expect(i.something).to be_eql Aws::Templates::Utils::Expressions::Number.new(1)
      end

      context 'with operations' do
        let(:expected) do
          Aws::Templates::Utils::Expressions::Functions::Operations::Arithmetic::Addition.new(
            Aws::Templates::Utils::Expressions::Variables::Arithmetic.new(:x),
            1
          )
        end

        it 'works with expressions in general' do
          i = test_class.new(something: test_class.expression { x + 1 })
          expect(i.something).to be_eql expected
        end

        it 'parses strings' do
          i = test_class.new(something: 'x + 1')
          expect(i.something).to be_eql expected
        end
      end
    end

    context 'with context-dependent block' do
      let(:test_class) do
        Class.new(parametrized_class) do
          include Aws::Templates::Utils::Expressions::Mixin

          parameter :variables,
                    constraint: not_nil,
                    transform: as_list

          parameter :something,
                    transform: as_expression { |i|
                      variables Hash[
                        i.variables.map do |name|
                          [name, Aws::Templates::Utils::Expressions::Variables::Arithmetic]
                        end
                      ]
                    }
        end
      end

      it 'works with boxable expressions' do
        i = test_class.new(variables: [:x], something: 1)
        expect(i.something).to be_eql Aws::Templates::Utils::Expressions::Number.new(1)
      end

      context 'with operations' do
        let(:expected) do
          Aws::Templates::Utils::Expressions::Functions::Operations::Arithmetic::Addition.new(
            Aws::Templates::Utils::Expressions::Variables::Arithmetic.new(:x),
            1
          )
        end

        it 'works with expressions in general' do
          i = test_class.new(variables: [:x], something: proc { x + 1 })
          expect(i.something).to be_eql expected
        end

        it 'parses strings' do
          i = test_class.new(variables: [:x], something: 'x + 1')
          expect(i.something).to be_eql expected
        end
      end
    end
  end
end
