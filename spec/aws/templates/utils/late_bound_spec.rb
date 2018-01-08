require 'spec_helper'
require 'aws/templates/utils/late_bound'

describe Aws::Templates::Utils::LateBound do
  let(:including_class) do
    Class.new do
      include Aws::Templates::Utils::LateBound
    end
  end

  let(:instance) { including_class.new }

  describe 'DSL' do
    it 'has parameter DSL class-level method' do
      expect(including_class).to respond_to(:reference)
    end

    it 'has parameter DSL instance-level method' do
      expect(including_class.new).to respond_to(:reference)
    end
  end

  describe 'behavior' do
    describe 'class' do
      let(:reference) { including_class.reference(%i[a b c], explosive: true) }

      let(:evaluated) { instance.instance_exec(&reference) }

      it 'creates proc for reference' do
        expect(reference).to be_a Proc
      end

      it 'is evaluated into normal reference' do
        expect(evaluated).to be_a Aws::Templates::Utils::LateBound::Reference
      end

      it 'contains assigned attributes' do
        expect([evaluated.path, evaluated.arguments, evaluated.instance])
          .to be == [%i[a b c], [{ explosive: true }], instance]
      end
    end

    describe 'instance' do
      let(:reference) { instance.reference(%i[a b c], explosive: true) }

      it 'is evaluated into normal reference' do
        expect([reference.path, reference.arguments, reference.instance])
          .to be == [%i[a b c], [{ explosive: true }], instance]
      end
    end
  end
end
