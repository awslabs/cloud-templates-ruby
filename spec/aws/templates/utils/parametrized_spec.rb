require 'spec_helper'
require 'aws/templates/utils/parametrized'

describe Aws::Templates::Utils::Parametrized do
  let(:including_class) do
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

  let(:including_module) do
    Module.new do
      include Aws::Templates::Utils::Parametrized

      parameter :mixed_parameter,
                description: 'Just a parameter which will be added ' \
                  'into including modules/classes',
                transform: ->(_, v) { v.to_s }
    end
  end

  describe 'module include' do
    it 'has parameter DSL method' do
      expect(including_module).to respond_to(:parameter)
    end

    it 'has accessor defined with the DSL' do
      expect(including_module.method_defined?(:mixed_parameter))
        .to be == true
    end

    it 'has parameter object defined with appropriate name' do
      expect(including_module.get_parameter(:mixed_parameter).name)
        .to be == :mixed_parameter
    end
  end

  describe 'class include' do
    it 'has parameter DSL method' do
      expect(including_class).to respond_to(:parameter)
    end
  end

  context 'Class is inherited and the module is included' do
    let(:parametrized_class) do
      INCLUDING_MODULE = including_module

      Class.new(including_class) do
        include INCLUDING_MODULE
      end
    end

    let(:create_parameters) { { mixed_parameter: 5 } }

    let(:instance) do
      parametrized_class.new(create_parameters)
    end

    it 'returns value of module parameter' do
      expect(instance.mixed_parameter).to be == '5'
    end
  end

  context 'Class is inherited and extended with parameters' do
    let(:parametrized_class) do
      Class.new(including_class) do
        parameter :all_properties_parameter,
                  description: 'Made to test the situation when all ' \
                    'properties are specified',
                  getter: lambda { |p|
                    options[p.name.to_s.sub('parameter', 'option').to_sym]
                  },
                  transform: ->(_, v) { v + 1 },
                  constraint: ->(_, v) { raise "it's > 3!" if v > 3 }

        parameter :bare_minimum,
                  description: '"Do defaults" type of parameter'
      end
    end

    it 'parameter objects have correct attributes' do
      expect(parametrized_class.get_parameter(:all_properties_parameter).name)
        .to be == :all_properties_parameter
    end

    describe 'DSL' do
      it 'has parameter DSL method' do
        expect(parametrized_class).to respond_to(:parameter)
      end
    end

    context 'Instance of the class created' do
      let(:create_parameters) {}

      let(:instance) do
        parametrized_class.new(create_parameters)
      end

      it 'contains all_properties_parameter as accessor' do
        expect(instance).to respond_to(:all_properties_parameter)
      end

      it 'contains bare_minimum as accessor' do
        expect(instance).to respond_to(:bare_minimum)
      end

      context 'with compliant parameters' do
        let(:create_parameters) do
          {
            all_properties_option: 2,
            bare_minimum: 5
          }
        end

        it 'returns all_properties_parameter correctly' do
          expect(instance.all_properties_parameter).to be == 3
        end

        it 'returns bare_minimum correctly' do
          expect(instance.bare_minimum).to be == 5
        end
      end

      context 'with parameters violating the constraint' do
        let(:create_parameters) do
          {
            all_properties_option: 3,
            bare_minimum: 5
          }
        end

        it 'raises an exception' do
          expect { instance.all_properties_parameter }.to raise_error RuntimeError
        end
      end
    end

    context 'Class is inherited and a parameter added' do
      let(:extending_class) do
        Class.new(parametrized_class) do
          parameter :just_addition,
                    description: 'Trying to add parameter to the ' \
                      'parent\'s parameter list'
        end
      end

      %i[just_addition all_properties_parameter bare_minimum].each do |name|
        it "has accessor #{name} inherited from parent" do
          expect(extending_class.method_defined?(name)).to be == true
        end

        it "has parameter #{name} inherited from parent" do
          expect(extending_class.get_parameter(name).name).to be == name
        end
      end

      context 'Instance of the class created' do
        let(:create_parameters) do
          {
            all_properties_option: 2,
            bare_minimum: 5,
            just_addition: 'bonus'
          }
        end

        let(:instance) do
          extending_class.new(create_parameters)
        end

        {
          all_properties_parameter: 3,
          bare_minimum: 5,
          just_addition: 'bonus'
        }.each_pair do |name, value|
          it "returns #{name} attributes correctly" do
            expect(instance.send(name)).to be == value
          end
        end
      end

      context 'Class inherited and parameter mixin added' do
        let(:mixing_class) do
          k = Class.new(extending_class)
          k.send(:include, including_module)
          k
        end

        %i[just_addition all_properties_parameter bare_minimum].each do |name|
          it "has accessor #{name} inherited from parent" do
            expect(mixing_class.method_defined?(name)).to be == true
          end

          it "has parameter #{name} inherited from parent" do
            expect(mixing_class.get_parameter(name).name).to be == name
          end
        end

        it 'has accessor mixed_parameter derived from mixin' do
          expect(mixing_class.method_defined?(:mixed_parameter)).to be == true
        end

        it 'has parameter mixed_parameter derived from mixin' do
          expect(mixing_class.get_parameter(:mixed_parameter).name)
            .to be == :mixed_parameter
        end
      end
    end

    it 'fails when trying to add existing parameter' do
      expect do
        Class.new(parametrized_class) do
          parameter :bare_minimum, description: 'Something existing'
        end
      end.to raise_error Aws::Templates::Exception::ParameterAlreadyExist
    end

    context 'method is defined' do
      let(:failing_class) do
        Class.new(parametrized_class) do
          def a; end
        end
      end

      it 'fails when adding a parameter with the same name as a method' do
        expect { failing_class.parameter(:a, description: 'Unexpected') }
          .to raise_error Aws::Templates::Exception::ParameterMethodNameConflict
      end
    end
  end
end
