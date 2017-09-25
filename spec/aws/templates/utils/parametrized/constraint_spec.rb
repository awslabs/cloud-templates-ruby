require 'spec_helper'
require 'aws/templates/utils/parametrized'
require 'aws/templates/utils/parametrized/constraints'
require 'aws/templates/utils/parametrized/getters'

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
        .to raise_error Aws::Templates::ParameterValueInvalid
    end
  end

  describe 'enum works as expected' do
    let(:constraint) { Constraints.enum(1, 2, 3) }

    it 'passes when a value from the list is specifed' do
      expect(test_class.new(something: 2).something).to be == 2
    end

    it 'passes when value is not specified' do
      expect(test_class.new(something_else: 2).something).to be_nil
    end

    it 'throws an error when a value is specified which is not a member of the enumeration' do
      expect { test_class.new(something: 5).something }
        .to raise_error Aws::Templates::ParameterValueInvalid
    end
  end

  describe 'all_of' do
    let(:constraint) { Constraints.all_of(Constraints.not_nil, Constraints.enum(1, 2, 3)) }

    it 'passes if all constraints are met' do
      expect(test_class.new(something: 2).something).to be == 2
    end

    it 'throws an error if one of the constraints are failed (not_nil)' do
      expect { test_class.new(something_else: 2).something }
        .to raise_error Aws::Templates::ParameterValueInvalid
    end

    it 'throws an error if one of the constraints are failed (enum)' do
      expect { test_class.new(something: 5).something }
        .to raise_error Aws::Templates::ParameterValueInvalid
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
        .to raise_error Aws::Templates::ParameterValueInvalid
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

    it 'passes when value is not one of the conditions' do
      expect(test_class.new(something: 2).something).to be == 2
    end

    it 'passes when conditional constraint is met' do
      expect(test_class.new(something: :condition, condition: 2).something)
        .to be == :condition
    end

    it 'throws an error when conditional constraint is not met' do
      expect { test_class.new(something: :condition, requirement: 2).something }
        .to raise_error Aws::Templates::ParameterValueInvalid
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
        .to raise_error Aws::Templates::ParameterValueInvalid
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
        .to raise_error Aws::Templates::ParameterValueInvalid
    end
  end
end
