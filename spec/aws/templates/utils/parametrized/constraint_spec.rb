require 'spec_helper'
require 'aws/templates/utils/parametrized'

module Constraints
  include Aws::Templates::Utils::Parametrized
end

describe Aws::Templates::Utils::Parametrized::Constraint do
  let(:constraint) {}

  let(:parametrized_class) do
    Class.new do
      include Aws::Templates::Utils::Parametrized

      attr_reader :options

      def self.getter
        as_is
      end

      def initialize(options)
        @options = options
      end
    end
  end

  let(:test_class) do
    k = Class.new(parametrized_class)
    k.parameter(:something, constraint: constraint)
    k
  end

  describe 'not_nil' do
    let(:constraint) { Constraints.not_nil }

    it 'passes when non-nil value is specified' do
      expect(test_class.new(something: 1).something).to be == 1
    end

    it 'throws error when parameter is not specified' do
      expect { test_class.new(something_else: 1).something }
        .to raise_error Aws::Templates::Exception::ParameterProcessingException
    end
  end

  describe 'enum' do
    let(:constraint) { Constraints.enum(1, 2, 3) }

    it 'passes when a value from the list is specifed' do
      expect(test_class.new(something: 2).something).to be == 2
    end

    it 'passes when value is not specified' do
      expect(test_class.new(something_else: 2).something).to be_nil
    end

    it 'throws an error when a value is specified which is not a member of the enumeration' do
      expect { test_class.new(something: 5).something }
        .to raise_error Aws::Templates::Exception::ParameterProcessingException
    end
  end

  describe 'all_of' do
    let(:constraint) { Constraints.all_of(Constraints.not_nil, Constraints.enum(1, 2, 3)) }

    it 'passes if all constraints are met' do
      expect(test_class.new(something: 2).something).to be == 2
    end

    it 'throws an error if one of the constraints are failed (not_nil)' do
      expect { test_class.new(something_else: 2).something }
        .to raise_error Aws::Templates::Exception::ParameterProcessingException
    end

    it 'throws an error if one of the constraints are failed (enum)' do
      expect { test_class.new(something: 5).something }
        .to raise_error Aws::Templates::Exception::ParameterProcessingException
    end
  end

  describe 'requires' do
    let(:test_class) do
      Class.new(parametrized_class) do
        parameter :something, constraint: requires(:requirement)
        parameter :requirement, description: 'Nothing'
      end
    end

    it 'passes when requirement is satisfied' do
      expect(test_class.new(something: 2, requirement: 1).something).to be == 2
    end

    it 'passes if value is nil so no requirements are enforced' do
      expect(test_class.new({}).something).to be_nil
    end

    it 'throws an error when requirement is not satisfied' do
      expect { test_class.new(something: 5).something }
        .to raise_error Aws::Templates::Exception::ParameterProcessingException
    end
  end

  describe 'depends_on_value' do
    let(:test_class) do
      Class.new(parametrized_class) do
        parameter :something,
                  constraint: depends_on_value(
                    requirement: requires(:requirement),
                    condition: requires(:condition)
                  )
        parameter :requirement, description: 'Nothing'
        parameter :condition, description: 'Nothing'
      end
    end

    it 'passes when nil' do
      expect(test_class.new({}).something).to be_nil
    end

    it 'passes when conditional constraint is met' do
      expect(test_class.new(something: :condition, condition: 2).something)
        .to be == :condition
    end

    it 'throws an error when conditional constraint is not met' do
      expect { test_class.new(something: :condition, requirement: 2).something }
        .to raise_error Aws::Templates::Exception::ParameterProcessingException
    end

    it 'passes when other conditional constraint is met' do
      expect(test_class.new(something: :requirement, requirement: 2).something)
        .to be == :requirement
    end
  end

  describe 'satisfies' do
    let(:constraint) { Constraints.satisfies('some interesting case') { |v| v > 3 } }

    it 'passes when nil' do
      expect(test_class.new({}).something).to be_nil
    end

    it 'passes when condition is satisfied' do
      expect(test_class.new(something: 4).something).to be == 4
    end

    it 'throws an error when condition is not satisfied' do
      expect { test_class.new(something: 1).something }
        .to raise_error Aws::Templates::Exception::ParameterProcessingException
    end
  end

  describe 'matches' do
    let(:constraint) { Constraints.matches('[Tt]$') }

    it 'passes when nil' do
      expect(test_class.new({}).something).to be_nil
    end

    it 'passes when condition is satisfied' do
      expect(test_class.new(something: 'rest').something).to be == 'rest'
    end

    it 'throws an error when condition is not satisfied' do
      expect { test_class.new(something: 'rooster').something }
        .to raise_error Aws::Templates::Exception::ParameterProcessingException
    end
  end

  describe 'module?' do
    context 'without base' do
      let(:constraint) { Constraints.module? }

      it 'ignores when nil' do
        expect(test_class.new({}).something).to be_nil
      end

      it 'succeeds when a Module is passed' do
        expect(test_class.new(something: ::Object).something).to be == ::Object
      end

      context 'with arbitrary object' do
        let(:exception) do
          begin
            test_class.new(something: 'Object').something
          rescue StandardError => e
            e
          end
        end

        it 'fails' do
          expect { test_class.new(something: 'Object').something }.to raise_error(
            Aws::Templates::Exception::ParameterProcessingException,
            /something/
          )
        end

        it 'fails constraint exception' do
          expect(exception.cause).to be_a Aws::Templates::Exception::ParameterConstraintException
        end

        it 'fails with correct message' do
          expect(exception.cause.cause.message).to match(/Object.*is not/)
        end
      end
    end

    context 'with base' do
      let(:constraint) { Constraints.module?(::Object) }

      it 'ignores when nil' do
        expect(test_class.new({}).something).to be_nil
      end

      it 'succeeds when a correct Module is passed' do
        expect(test_class.new(something: ::String).something).to be == ::String
      end

      context 'when arbitrary Module is passed' do
        let(:exception) do
          begin
            test_class.new(something: ::BasicObject).something
          rescue StandardError => e
            e
          end
        end

        it 'fails' do
          expect { test_class.new(something: ::BasicObject).something }.to raise_error(
            Aws::Templates::Exception::ParameterProcessingException,
            /something/
          )
        end

        it 'fails constraint exception' do
          expect(exception.cause).to be_a Aws::Templates::Exception::ParameterConstraintException
        end

        it 'fails with correct message' do
          expect(exception.cause.cause.message).to match(/BasicObject is not a child of Object/)
        end
      end
    end
  end

  describe 'is?' do
    context 'with class' do
      let(:constraint) { Constraints.is?(::Enumerable) }

      it 'passes when nil' do
        expect(test_class.new({}).something).to be_nil
      end

      it 'passes when an instance of the class is passed' do
        expect(test_class.new(something: []).something).to be == []
      end

      it 'throws an error when wrong object is passed' do
        expect { test_class.new(something: 123).something }
          .to raise_error Aws::Templates::Exception::ParameterProcessingException
      end
    end

    context 'with class and attributes' do
      let(:constraint) do
        Constraints.is?(
          ::String => Constraints.satisfies('big') { |v| v.to_s.length > 5 }
        )
      end

      it 'passes when nil' do
        expect(test_class.new({}).something).to be_nil
      end

      it 'passes when an object with satisfying condition is passed' do
        expect(test_class.new(something: '123456').something).to be == '123456'
      end

      it 'throws an error when the object doesn\'t satisfy condition' do
        expect { test_class.new(something: '12345').something }
          .to raise_error Aws::Templates::Exception::ParameterProcessingException
      end

      it 'throws an error when wrong object is passed' do
        expect { test_class.new(something: 123_456).something }
          .to raise_error Aws::Templates::Exception::ParameterProcessingException
      end
    end
  end

  describe 'has?' do
    context 'without field constraints' do
      let(:constraint) { Constraints.has?(:to_str) }

      it 'passes when nil' do
        expect(test_class.new({}).something).to be_nil
      end

      it 'passes when the object has the field' do
        expect(test_class.new(something: '123456').something).to be == '123456'
      end

      it 'fails when the object doesn\'t have the field' do
        expect { test_class.new(something: true).something }
          .to raise_error Aws::Templates::Exception::ParameterProcessingException
      end
    end

    context 'with field constraints' do
      let(:constraint) do
        Constraints.has?(to_str: Constraints.satisfies('big') { |v| v.length > 5 })
      end

      it 'passes when nil' do
        expect(test_class.new({}).something).to be_nil
      end

      it 'passes when the field satisfies the constraint' do
        expect(test_class.new(something: '123456').something).to be == '123456'
      end

      it 'fails when the field fails the constraint' do
        expect { test_class.new(something: '123').something }
          .to raise_error Aws::Templates::Exception::ParameterProcessingException
      end
    end
  end
end
