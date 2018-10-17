require 'spec_helper'

describe Aws::Templates::Utils::LateBound do
  let(:klass) do
    Class.new do
      include Aws::Templates::Utils::Parametrized

      parameter :wildcard, getter: late_bound

      parameter :constrained,
                getter: late_bound,
                constraint: not_nil

      parameter :typed,
                getter: late_bound,
                transform: as_string

      parameter :typed_and_constrained,
                getter: late_bound,
                transform: as_string,
                constraint: not_nil

      parameter :late_index,
                getter: late_bound,
                transform: as_integer,
                constraint: not_nil

      parameter :late_list,
                getter: late_bound,
                transform: as_list(
                  name: :element,
                  constraint: not_nil,
                  transform: as_integer
                ),
                constraint: not_nil

      parameter :late_map,
                getter: late_bound,
                transform: as_hash {
                  key transform: as_string,
                      constraint: not_nil

                  value transform: as_integer,
                        constraint: not_nil
                },
                constraint: not_nil

      parameter :late_struct,
                getter: late_bound,
                transform: as_object {
                  parameter :wildcard
                  parameter :constrained, constraint: not_nil
                  parameter :typed, transform: as_string
                }
    end
  end

  let(:instance) { klass.new }
  let(:link) { value.link }
  let(:name) { :none }
  let(:concept) { klass.get_parameter(name).concept }
  let(:transform) { concept.transform }
  let(:constraint) { concept.constraint }

  describe 'wildcard' do
    let(:value) { instance.wildcard }
    let(:name) { :wildcard }

    describe 'value' do
      it 'has correct class' do
        expect(value).to be_a(Aws::Templates::Utils::LateBound::Values::Empty)
      end

      describe 'constraint' do
        it 'fails when something constrained is required' do
          expect { instance.instance_exec(value, &klass.not_nil) }
            .to raise_error Aws::Templates::Exception::ParameterRuntimeException
        end
      end

      describe 'transform' do
        it 'fails when something typed is required' do
          expect { instance.instance_exec(value, &klass.as_string) }
            .to raise_error Aws::Templates::Exception::ParameterRuntimeException
        end
      end
    end

    describe 'link' do
      it 'has correct link class' do
        expect(link).to be_a(Aws::Templates::Utils::LateBound::MethodLink)
      end

      it 'has correct field name' do
        expect(link.name).to be == :wildcard
      end

      it 'has correct parent' do
        expect(link.parent).to be == instance
      end

      it 'is root' do
        expect(link).to be_root
      end
    end
  end

  describe 'constrained' do
    let(:value) { instance.constrained }
    let(:name) { :constrained }

    describe 'value' do
      it 'has correct class' do
        expect(instance.constrained).to be_a(Aws::Templates::Utils::LateBound::Values::Value)
      end

      it 'can be passed as a value' do
        expect(instance.instance_exec(value, &concept))
          .to be_a(Aws::Templates::Utils::LateBound::Values::Value)
      end

      describe 'constraint' do
        it 'has correct constraint attached' do
          expect(value.constraint).to be_satisfies(constraint)
        end

        it 'can be processed with constraint functor' do
          expect { instance.instance_exec(value, &constraint) }.not_to raise_error
        end

        it 'would fail arbitrary constraint' do
          expect { instance.instance_exec(value, &klass.matches('1')) }
            .to raise_error Aws::Templates::Exception::ParameterRuntimeException
        end
      end

      describe 'transform' do
        it 'fails when something typed is required' do
          expect { instance.instance_exec(value, &klass.as_string) }
            .to raise_error Aws::Templates::Exception::ParameterRuntimeException
        end
      end
    end

    describe 'link' do
      it 'has correct link class' do
        expect(link).to be_a(Aws::Templates::Utils::LateBound::MethodLink)
      end

      it 'has correct field name' do
        expect(link.name).to be == :constrained
      end

      it 'has correct parent' do
        expect(link.parent).to be == instance
      end

      it 'is root' do
        expect(link).to be_root
      end
    end
  end

  describe 'typed' do
    let(:value) { instance.typed }
    let(:name) { :typed }

    describe 'value' do
      it 'has correct class' do
        expect(value).to be_a(Aws::Templates::Utils::LateBound::Values::Scalar)
      end

      it 'can be passed as a value' do
        expect(instance.instance_exec(value, &concept))
          .to be_a(Aws::Templates::Utils::LateBound::Values::Scalar)
      end

      describe 'transform' do
        it 'has correct constraint attached' do
          expect(value.transform).to be_processable_by(transform)
        end

        it 'can be processed with transform functor' do
          expect { instance.instance_exec(value, &transform) }.not_to raise_error
        end

        it 'would fail arbitrary transform' do
          expect { instance.instance_exec(value, &klass.as_float) }
            .to raise_error Aws::Templates::Exception::ParameterRuntimeException
        end
      end

      describe 'constraint' do
        it 'fails when something constrained is required' do
          expect { instance.instance_exec(value, &klass.not_nil) }
            .to raise_error Aws::Templates::Exception::ParameterRuntimeException
        end
      end
    end

    describe 'link' do
      let(:link) { value.link }

      it 'has correct link class' do
        expect(link).to be_a(Aws::Templates::Utils::LateBound::MethodLink)
      end

      it 'has correct field name' do
        expect(link.name).to be == :typed
      end

      it 'has correct parent' do
        expect(link.parent).to be == instance
      end

      it 'is root' do
        expect(link).to be_root
      end
    end
  end

  describe 'typed_and_constrained' do
    let(:value) { instance.typed_and_constrained }
    let(:name) { :typed_and_constrained }

    describe 'value' do
      it 'has correct class' do
        expect(value).to be_a(Aws::Templates::Utils::LateBound::Values::Scalar)
      end

      it 'can be passed as a value' do
        expect(instance.instance_exec(value, &concept))
          .to be_a(Aws::Templates::Utils::LateBound::Values::Scalar)
      end

      describe 'transform' do
        it 'has correct transform attached' do
          expect(value.transform).to be_processable_by(transform)
        end

        it 'can be processed with transform functor' do
          expect { instance.instance_exec(value, &transform) }.not_to raise_error
        end

        it 'would fail arbitrary transform' do
          expect { instance.instance_exec(value, &klass.as_float) }
            .to raise_error Aws::Templates::Exception::ParameterRuntimeException
        end
      end

      describe 'constraint' do
        it 'has correct constraint attached' do
          expect(value.constraint).to be_satisfies(constraint)
        end

        it 'can be processed with constraint functor' do
          expect { instance.instance_exec(value, &constraint) }.not_to raise_error
        end

        it 'would fail arbitrary constraint' do
          expect { instance.instance_exec(value, &klass.matches('1')) }
            .to raise_error Aws::Templates::Exception::ParameterRuntimeException
        end
      end
    end

    describe 'link' do
      it 'has correct link class' do
        expect(link).to be_a(Aws::Templates::Utils::LateBound::MethodLink)
      end

      it 'has correct field name' do
        expect(link.name).to be == :typed_and_constrained
      end

      it 'has correct parent' do
        expect(link.parent).to be == instance
      end

      it 'is root' do
        expect(link).to be_root
      end
    end
  end

  describe 'late_list' do
    let(:value) { instance.late_list }
    let(:name) { :late_list }

    describe 'value' do
      it 'has correct class' do
        expect(value).to be_a(Aws::Templates::Utils::LateBound::Values::Containers::List)
      end

      it 'can be passed as a value' do
        expect(instance.instance_exec(value, &concept))
          .to be_a(Aws::Templates::Utils::LateBound::Values::Containers::List)
      end

      describe 'transform' do
        it 'has correct transform attached' do
          expect(value.transform).to be_processable_by(transform)
        end

        it 'can be processed with transform functor' do
          expect { instance.instance_exec(value, &transform) }.not_to raise_error
        end

        it 'would fail arbitrary transform' do
          expect { instance.instance_exec(value, &klass.as_float) }
            .to raise_error Aws::Templates::Exception::ParameterRuntimeException
        end

        it 'would fail transform with different element type' do
          expect { instance.instance_exec(value, &klass.as_list(transform: klass.as_json)) }
            .to raise_error Aws::Templates::Exception::ParameterRuntimeException
        end

        it 'satisfies list with loosened element constraint' do
          expect(instance.instance_exec(value, &klass.as_list(transform: klass.as_integer)))
            .to be == value
        end
      end

      describe 'element' do
        it 'fails when arbitrary object passed as index' do
          expect { value[{}] }.to raise_error Aws::Templates::Exception::ParameterRuntimeException
        end

        it 'fails when index is nil' do
          expect { value[nil] }.to raise_error Aws::Templates::Exception::ParameterRuntimeException
        end

        it 'fails when incompatible late bound value is passed as index' do
          expect { value[instance.typed_and_constrained] }
            .to raise_error Aws::Templates::Exception::ParameterRuntimeException
        end

        context 'with literal index' do
          let(:element) { value[1] }

          it 'has correct class' do
            expect(element).to be_a(Aws::Templates::Utils::LateBound::Values::Scalar)
          end

          it 'transforms into the correct string' do
            expect(element.to_s).to match(/Object\(\d+\)\.method\(:late_list\)\.index\(1\)/)
          end

          describe 'transform' do
            it 'has correct transform attached' do
              expect(element.transform).to be_processable_by(klass.as_integer)
            end

            it 'can be processed with transform functor' do
              expect { instance.instance_exec(element, &klass.as_integer) }.not_to raise_error
            end

            it 'would fail arbitrary transform' do
              expect { instance.instance_exec(element, &klass.as_float) }
                .to raise_error Aws::Templates::Exception::ParameterRuntimeException
            end
          end

          describe 'constraint' do
            it 'has correct constraint attached' do
              expect(element.constraint).to be_satisfies(klass.not_nil)
            end

            it 'can be processed with constraint functor' do
              expect { instance.instance_exec(element, &klass.not_nil) }.not_to raise_error
            end

            it 'would fail arbitrary constraint' do
              expect { instance.instance_exec(element, &klass.matches('1')) }
                .to raise_error Aws::Templates::Exception::ParameterRuntimeException
            end
          end

          describe 'link' do
            let(:link) { element.link }

            it 'has correct link class' do
              expect(link)
                .to be_a(Aws::Templates::Utils::LateBound::Values::Containers::List::Index)
            end

            it 'has correct index' do
              expect(link.selector).to be == 1
            end

            it 'has correct parent' do
              expect(link.parent).to be == value
            end

            it 'is not root' do
              expect(link).not_to be_root
            end

            it 'has correct path' do
              expect(link.path).to match(/^Object\(\d+\)\.method\(:late_list\)\.index\(1\)$/)
            end
          end
        end

        context 'with late bound index' do
          let(:element) { value[instance.late_index] }

          let(:stringified) do
            'Object\\(\\d+\\)\\.method\\(:late_list\\)\\.index\\(' \
              'LateBound\\(Object\\(\\d+\\)\\.method\\(:late_index\\)\\)' \
            '\\)'
          end

          it 'has correct class' do
            expect(element).to be_a(Aws::Templates::Utils::LateBound::Values::Scalar)
          end

          it 'transforms into the correct string' do
            expect(element.to_s).to match(stringified)
          end
        end
      end

      describe 'constraint' do
        it 'has correct constraint attached' do
          expect(value.constraint).to be_satisfies(constraint)
        end

        it 'can be processed with constraint functor' do
          expect { instance.instance_exec(value, &constraint) }.not_to raise_error
        end

        it 'would fail arbitrary constraint' do
          expect { instance.instance_exec(value, &klass.matches('1')) }
            .to raise_error Aws::Templates::Exception::ParameterRuntimeException
        end
      end
    end

    describe 'link' do
      it 'has correct link class' do
        expect(link).to be_a(Aws::Templates::Utils::LateBound::MethodLink)
      end

      it 'has correct field name' do
        expect(link.name).to be == :late_list
      end

      it 'has correct parent' do
        expect(link.parent).to be == instance
      end

      it 'is root' do
        expect(link).to be_root
      end
    end
  end

  describe 'late_map' do
    let(:value) { instance.late_map }
    let(:name) { :late_map }

    describe 'value' do
      it 'has correct class' do
        expect(value).to be_a(Aws::Templates::Utils::LateBound::Values::Containers::Map)
      end

      it 'can be passed as a value' do
        expect(instance.instance_exec(value, &concept))
          .to be_a(Aws::Templates::Utils::LateBound::Values::Containers::Map)
      end

      describe 'transform' do
        it 'has correct transform attached' do
          expect(value.transform).to be_processable_by(transform)
        end

        it 'can be processed with transform functor' do
          expect { instance.instance_exec(value, &transform) }.not_to raise_error
        end

        it 'would fail arbitrary transform' do
          expect { instance.instance_exec(value, &klass.as_float) }
            .to raise_error Aws::Templates::Exception::ParameterRuntimeException
        end

        context 'with different key type' do
          let(:target_transform) do
            klass.as_hash do
              key transform: as_float
              value transform: as_integer
            end
          end

          it 'fails transform' do
            expect { instance.instance_exec(value, &target_transform) }
              .to raise_error Aws::Templates::Exception::ParameterRuntimeException
          end
        end

        context 'with different value type' do
          let(:target_transform) do
            klass.as_hash do
              key transform: as_string
              value transform: as_string
            end
          end

          it 'fails transform' do
            expect { instance.instance_exec(value, &target_transform) }
              .to raise_error Aws::Templates::Exception::ParameterRuntimeException
          end
        end

        context 'without any constraints' do
          it 'is processed by the transform' do
            expect(instance.instance_exec(value, &klass.as_hash)).to be == value
          end
        end

        context 'with loosened constraints' do
          let(:target_transform) do
            klass.as_hash do
              key transform: as_string
              value transform: as_integer
            end
          end

          it 'is processed by the transform' do
            expect(instance.instance_exec(value, &klass.as_hash)).to be == value
          end
        end
      end

      describe 'element' do
        it 'fails when key is nil' do
          expect { value[nil] }.to raise_error Aws::Templates::Exception::ParameterRuntimeException
        end

        it 'fails when incompatible late bound value is passed as key' do
          expect { value[instance.late_index] }
            .to raise_error Aws::Templates::Exception::ParameterRuntimeException
        end

        it 'fails when unrestricted late bound value is passed as key' do
          expect { value[instance.typed] }
            .to raise_error Aws::Templates::Exception::ParameterRuntimeException
        end

        context 'with literal key' do
          let(:element) { value['s'] }

          it 'has correct class' do
            expect(element).to be_a(Aws::Templates::Utils::LateBound::Values::Scalar)
          end

          it 'transforms into the correct string' do
            expect(element.to_s).to match(/Object\(\d+\)\.method\(:late_map\)\.key\("s"\)/)
          end

          describe 'transform' do
            it 'has correct transform attached' do
              expect(element.transform).to be_processable_by(klass.as_integer)
            end

            it 'can be processed with transform functor' do
              expect { instance.instance_exec(element, &klass.as_integer) }.not_to raise_error
            end

            it 'would fail arbitrary transform' do
              expect { instance.instance_exec(element, &klass.as_float) }
                .to raise_error Aws::Templates::Exception::ParameterRuntimeException
            end
          end

          describe 'constraint' do
            it 'has correct constraint attached' do
              expect(element.constraint).to be_satisfies(klass.not_nil)
            end

            it 'can be processed with constraint functor' do
              expect { instance.instance_exec(element, &klass.not_nil) }.not_to raise_error
            end

            it 'would fail arbitrary constraint' do
              expect { instance.instance_exec(element, &klass.matches('1')) }
                .to raise_error Aws::Templates::Exception::ParameterRuntimeException
            end
          end

          describe 'link' do
            let(:link) { element.link }

            it 'has correct link class' do
              expect(link)
                .to be_a(Aws::Templates::Utils::LateBound::Values::Containers::Map::Index)
            end

            it 'has correct index' do
              expect(link.selector).to be == 's'
            end

            it 'has correct parent' do
              expect(link.parent).to be == value
            end

            it 'is not root' do
              expect(link).not_to be_root
            end

            it 'has correct path' do
              expect(link.path).to match(/^Object\(\d+\)\.method\(:late_map\)\.key\("s"\)$/)
            end
          end
        end

        context 'with late bound index' do
          let(:element) { value[instance.typed_and_constrained] }

          let(:stringified) do
            'Object\\(\\d+\\)\\.method\\(:late_map\\)\\.key\\(' \
              'LateBound\\(Object\\(\\d+\\)\\.method\\(:typed_and_constrained\\)\\)' \
            '\\)'
          end

          it 'has correct class' do
            expect(element).to be_a(Aws::Templates::Utils::LateBound::Values::Scalar)
          end

          it 'transforms into the correct string' do
            expect(element.to_s).to match(stringified)
          end
        end
      end

      describe 'constraint' do
        it 'has correct constraint attached' do
          expect(value.constraint).to be_satisfies(constraint)
        end

        it 'can be processed with constraint functor' do
          expect { instance.instance_exec(value, &constraint) }.not_to raise_error
        end

        it 'would fail arbitrary constraint' do
          expect { instance.instance_exec(value, &klass.matches('1')) }
            .to raise_error Aws::Templates::Exception::ParameterRuntimeException
        end
      end
    end

    describe 'link' do
      it 'has correct link class' do
        expect(link).to be_a(Aws::Templates::Utils::LateBound::MethodLink)
      end

      it 'has correct field name' do
        expect(link.name).to be == :late_map
      end

      it 'has correct parent' do
        expect(link.parent).to be == instance
      end

      it 'is root' do
        expect(link).to be_root
      end
    end
  end

  describe 'late_struct' do
    let(:value) { instance.late_struct }
    let(:name) { :late_struct }

    describe 'value' do
      it 'has correct class' do
        expect(value).to be_a(Aws::Templates::Utils::LateBound::Values::Structure)
      end

      context 'when passed as value' do
        let(:processed) { instance.instance_exec(value, &concept) }

        it 'yields nested object' do
          expect(processed).to be_a(Aws::Templates::Utils::Parametrized::Nested)
        end

        describe 'fields' do
          describe 'wildcard' do
            let(:field) { processed.wildcard }

            it 'has correct class' do
              expect(field).to be_a(Aws::Templates::Utils::LateBound::Values::Empty)
            end

            describe 'constraint' do
              it 'fails when something constrained is required' do
                expect { processed.instance_exec(field, &klass.not_nil) }
                  .to raise_error Aws::Templates::Exception::ParameterRuntimeException
              end
            end

            describe 'transform' do
              it 'fails when something typed is required' do
                expect { processed.instance_exec(field, &klass.as_string) }
                  .to raise_error Aws::Templates::Exception::ParameterRuntimeException
              end
            end

            it 'is correctly transformable to string' do
              expect(field.to_s).to match(
                'Object\\(\\d+\\)\\.method\\(:late_struct\\)\\.method\\(:wildcard\\)'
              )
            end
          end

          describe 'constrained' do
            let(:field) { processed.constrained }

            it 'has correct class' do
              expect(instance.constrained)
                .to be_a(Aws::Templates::Utils::LateBound::Values::Value)
            end

            describe 'constraint' do
              it 'has correct constraint attached' do
                expect(field.constraint).to be_satisfies(klass.not_nil)
              end

              it 'can be processed with constraint functor' do
                expect { processed.instance_exec(field, &klass.not_nil) }.not_to raise_error
              end

              it 'would fail arbitrary constraint' do
                expect { processed.instance_exec(field, &klass.matches('1')) }
                  .to raise_error Aws::Templates::Exception::ParameterRuntimeException
              end
            end

            describe 'transform' do
              it 'fails when something typed is required' do
                expect { processed.instance_exec(field, &klass.as_string) }
                  .to raise_error Aws::Templates::Exception::ParameterRuntimeException
              end
            end

            it 'is correctly transformable to string' do
              expect(field.to_s).to match(
                'Object\\(\\d+\\)\\.method\\(:late_struct\\)\\.method\\(:constrained\\)'
              )
            end
          end

          describe 'typed' do
            let(:field) { processed.typed }

            it 'has correct class' do
              expect(field).to be_a(Aws::Templates::Utils::LateBound::Values::Scalar)
            end

            describe 'transform' do
              it 'has correct constraint attached' do
                expect(field.transform).to be_processable_by(klass.as_string)
              end

              it 'can be processed with transform functor' do
                expect { processed.instance_exec(field, &klass.as_string) }.not_to raise_error
              end

              it 'would fail arbitrary transform' do
                expect { processed.instance_exec(field, &klass.as_float) }
                  .to raise_error Aws::Templates::Exception::ParameterRuntimeException
              end
            end

            describe 'constraint' do
              it 'fails when something constrained is required' do
                expect { processed.instance_exec(field, &klass.not_nil) }
                  .to raise_error Aws::Templates::Exception::ParameterRuntimeException
              end
            end

            it 'is correctly transformable to string' do
              expect(field.to_s).to match(
                'Object\\(\\d+\\)\\.method\\(:late_struct\\)\\.method\\(:typed\\)'
              )
            end
          end
        end
      end

      describe 'fields' do
        describe 'wildcard' do
          let(:field) { value.wildcard }

          it 'has correct class' do
            expect(field).to be_a(Aws::Templates::Utils::LateBound::Values::Empty)
          end

          it 'is correctly transformable to string' do
            expect(field.to_s).to match(
              'Object\\(\\d+\\)\\.method\\(:late_struct\\)\\.method\\(:wildcard\\)'
            )
          end
        end

        describe 'constrained' do
          let(:field) { value.constrained }

          it 'has correct class' do
            expect(instance.constrained)
              .to be_a(Aws::Templates::Utils::LateBound::Values::Value)
          end

          it 'is correctly transformable to string' do
            expect(field.to_s).to match(
              'Object\\(\\d+\\)\\.method\\(:late_struct\\)\\.method\\(:constrained\\)'
            )
          end
        end

        describe 'typed' do
          let(:field) { value.typed }

          it 'has correct class' do
            expect(field).to be_a(Aws::Templates::Utils::LateBound::Values::Scalar)
          end

          it 'is correctly transformable to string' do
            expect(field.to_s).to match(
              'Object\\(\\d+\\)\\.method\\(:late_struct\\)\\.method\\(:typed\\)'
            )
          end
        end
      end

      describe 'transform' do
        it 'can be processed with transform functor' do
          expect { instance.instance_exec(value, &transform) }.not_to raise_error
        end

        it 'would fail arbitrary transform' do
          expect { instance.instance_exec(value, &klass.as_float) }
            .to raise_error Aws::Templates::Exception::ParameterRuntimeException
        end
      end
    end

    describe 'link' do
      it 'has correct link class' do
        expect(link).to be_a(Aws::Templates::Utils::LateBound::MethodLink)
      end

      it 'has correct field name' do
        expect(link.name).to be == :late_struct
      end

      it 'has correct parent' do
        expect(link.parent).to be == instance
      end

      it 'is root' do
        expect(link).to be_root
      end
    end
  end
end
