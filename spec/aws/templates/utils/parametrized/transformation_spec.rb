require 'spec_helper'
require 'aws/templates/utils/parametrized'
require 'aws/templates/render'
require 'polyglot'
require 'treetop'
require 'test_grammar'

module TestRender
  extend Aws::Templates::Render
  StringView = Class.new(Aws::Templates::Render::BasicView) do
    def to_rendered
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

    it 'fails if the value can be transformed to an array' do
      expect { test_class.new(something: 'abc').something }
        .to raise_error Aws::Templates::Exception::ParameterProcessingException
    end

    it 'returns correct value if sub-constraints are satisfied' do
      expect(test_class.new(something_else: [1, 2, 3]).something_else).to be == [1, 2, 3]
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
  end

  describe 'as_rendered' do
    let(:render) { TestRender }

    let(:test_class) do
      klass = Class.new(parametrized_class)
      klass.parameter :something, transform: klass.as_rendered(render)
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

    it 'looks up class name' do
      i = test_class.new(something: { q: 1 })
      expect(i.something).to be == '{"q":1}'
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
  end

  describe 'as_expression' do
    let(:test_class) do
      Class.new(parametrized_class) do
        include Aws::Templates::Utils::Expressions::Mixin

        define_expressions do
          variables x: Aws::Templates::Utils::Expressions::Variables::Arithmetic
        end

        parameter :something,
                  transform: as_expression(expressions_definition)
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
end
