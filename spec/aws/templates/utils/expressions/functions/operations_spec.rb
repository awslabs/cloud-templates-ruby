require 'spec_helper'

describe Aws::Templates::Utils::Expressions::Functions::Operations do
  let(:definition) do
    Aws::Templates::Utils::Expressions::Definition.new do
      variables x: Aws::Templates::Utils::Expressions::Variables::Arithmetic,
                y: Aws::Templates::Utils::Expressions::Variables::Arithmetic,
                z: Aws::Templates::Utils::Expressions::Variables::Arithmetic

      variables a: Aws::Templates::Utils::Expressions::Variables::Logical,
                b: Aws::Templates::Utils::Expressions::Variables::Logical,
                c: Aws::Templates::Utils::Expressions::Variables::Logical
    end
  end

  let(:dsl) do
    Aws::Templates::Utils::Expressions::Dsl.new(definition)
  end

  let(:parser) do
    Aws::Templates::Utils::Expressions::Parser.with(definition)
  end

  shared_examples 'operation' do
    it 'is the same for parsed and dsl' do
      expect(dsl_expression).to be_eql parsed_expression
    end

    it 'equals to expected output' do
      expect(dsl_expression).to be_eql expected
    end
  end

  describe 'logical' do
    describe '&' do
      let(:dsl_expression) do
        dsl.expression { a & b & true }
      end

      let(:parsed_expression) do
        parser.parse('a & b & true')
      end

      let(:expected) do
        Aws::Templates::Utils::Expressions::Functions::Operations::Logical::And.new(
          Aws::Templates::Utils::Expressions::Functions::Operations::Logical::And.new(
            Aws::Templates::Utils::Expressions::Variables::Logical.new(:a),
            Aws::Templates::Utils::Expressions::Variables::Logical.new(:b)
          ),
          true
        )
      end

      it_behaves_like 'operation'
    end

    describe '!' do
      let(:dsl_expression) do
        dsl.expression { !a }
      end

      let(:parsed_expression) do
        parser.parse('!a')
      end

      let(:expected) do
        Aws::Templates::Utils::Expressions::Functions::Operations::Logical::Not.new(
          Aws::Templates::Utils::Expressions::Variables::Logical.new(:a)
        )
      end

      it_behaves_like 'operation'
    end

    describe '|' do
      let(:dsl_expression) do
        dsl.expression { a | b | true }
      end

      let(:parsed_expression) do
        parser.parse('a | b | true')
      end

      let(:expected) do
        Aws::Templates::Utils::Expressions::Functions::Operations::Logical::Or.new(
          Aws::Templates::Utils::Expressions::Functions::Operations::Logical::Or.new(
            Aws::Templates::Utils::Expressions::Variables::Logical.new(:a),
            Aws::Templates::Utils::Expressions::Variables::Logical.new(:b)
          ),
          true
        )
      end

      it_behaves_like 'operation'
    end

    describe 'expression' do
      let(:dsl_expression) do
        dsl.expression { a | b | !c & a & (b | c) }
      end

      let(:parsed_expression) do
        parser.parse('a | b | !c & a & (b | c)')
      end

      let(:expected) do
        Aws::Templates::Utils::Expressions::Functions::Operations::Logical::Or.new(
          Aws::Templates::Utils::Expressions::Functions::Operations::Logical::Or.new(
            Aws::Templates::Utils::Expressions::Variables::Logical.new(:a),
            Aws::Templates::Utils::Expressions::Variables::Logical.new(:b)
          ),
          Aws::Templates::Utils::Expressions::Functions::Operations::Logical::And.new(
            Aws::Templates::Utils::Expressions::Functions::Operations::Logical::And.new(
              Aws::Templates::Utils::Expressions::Functions::Operations::Logical::Not.new(
                Aws::Templates::Utils::Expressions::Variables::Logical.new(:c)
              ),
              Aws::Templates::Utils::Expressions::Variables::Logical.new(:a)
            ),
            Aws::Templates::Utils::Expressions::Functions::Operations::Logical::Or.new(
              Aws::Templates::Utils::Expressions::Variables::Logical.new(:b),
              Aws::Templates::Utils::Expressions::Variables::Logical.new(:c)
            )
          )
        )
      end

      it_behaves_like 'operation'
    end
  end

  describe 'comparison' do
    describe '>' do
      let(:dsl_expression) do
        dsl.expression { x > 1 }
      end

      let(:parsed_expression) do
        parser.parse('x > 1')
      end

      let(:expected) do
        Aws::Templates::Utils::Expressions::Functions::Operations::Comparisons::Greater.new(
          Aws::Templates::Utils::Expressions::Variables::Arithmetic.new(:x),
          Aws::Templates::Utils::Expressions::Number.new(1)
        )
      end

      it_behaves_like 'operation'
    end

    describe '<' do
      let(:dsl_expression) do
        dsl.expression { x < 1 }
      end

      let(:parsed_expression) do
        parser.parse('x < 1')
      end

      let(:expected) do
        Aws::Templates::Utils::Expressions::Functions::Operations::Comparisons::Less.new(
          Aws::Templates::Utils::Expressions::Variables::Arithmetic.new(:x),
          Aws::Templates::Utils::Expressions::Number.new(1)
        )
      end

      it_behaves_like 'operation'
    end

    describe '>=' do
      let(:dsl_expression) do
        dsl.expression { x >= 1 }
      end

      let(:parsed_expression) do
        parser.parse('x >= 1')
      end

      let(:expected) do
        Aws::Templates::Utils::Expressions::Functions::Operations::Comparisons::GreaterOrEqual.new(
          Aws::Templates::Utils::Expressions::Variables::Arithmetic.new(:x),
          Aws::Templates::Utils::Expressions::Number.new(1)
        )
      end

      it_behaves_like 'operation'
    end

    describe '<=' do
      let(:dsl_expression) do
        dsl.expression { x <= 1 }
      end

      let(:parsed_expression) do
        parser.parse('x <= 1')
      end

      let(:expected) do
        Aws::Templates::Utils::Expressions::Functions::Operations::Comparisons::LessOrEqual.new(
          Aws::Templates::Utils::Expressions::Variables::Arithmetic.new(:x),
          Aws::Templates::Utils::Expressions::Number.new(1)
        )
      end

      it_behaves_like 'operation'
    end

    describe '!=' do
      let(:dsl_expression) do
        dsl.expression { x != 1 }
      end

      let(:parsed_expression) do
        parser.parse('x != 1')
      end

      let(:expected) do
        Aws::Templates::Utils::Expressions::Functions::Operations::Comparisons::NotEqual.new(
          Aws::Templates::Utils::Expressions::Variables::Arithmetic.new(:x),
          Aws::Templates::Utils::Expressions::Number.new(1)
        )
      end

      it_behaves_like 'operation'
    end

    describe '!~' do
      let(:dsl_expression) do
        dsl.expression { x !~ range(inclusive(1), exclusive(2)) }
      end

      let(:parsed_expression) do
        parser.parse('x !~ range(inclusive(1), exclusive(2))')
      end

      let(:expected) do
        Aws::Templates::Utils::Expressions::Functions::Operations::Range::Outside.new(
          Aws::Templates::Utils::Expressions::Variables::Arithmetic.new(:x),
          Aws::Templates::Utils::Expressions::Functions::Range.new(
            Aws::Templates::Utils::Expressions::Functions::Range::Border::Inclusive.new(1),
            Aws::Templates::Utils::Expressions::Functions::Range::Border::Exclusive.new(2)
          )
        )
      end

      it_behaves_like 'operation'
    end

    describe '=~' do
      let(:dsl_expression) do
        dsl.expression { x =~ range(inclusive(1), exclusive(2)) }
      end

      let(:parsed_expression) do
        parser.parse('x =~ range(inclusive(1), exclusive(2))')
      end

      let(:expected) do
        Aws::Templates::Utils::Expressions::Functions::Operations::Range::Inside.new(
          Aws::Templates::Utils::Expressions::Variables::Arithmetic.new(:x),
          Aws::Templates::Utils::Expressions::Functions::Range.new(
            Aws::Templates::Utils::Expressions::Functions::Range::Border::Inclusive.new(1),
            Aws::Templates::Utils::Expressions::Functions::Range::Border::Exclusive.new(2)
          )
        )
      end

      it_behaves_like 'operation'
    end

    describe 'combined' do
      let(:dsl_expression) do
        dsl.expression { (x =~ range(inclusive(1), exclusive(2))) | (y > 1) }
      end

      let(:parsed_expression) do
        parser.parse('(x =~ range(inclusive(1), exclusive(2))) | (y > 1)')
      end

      let(:expected) do
        Aws::Templates::Utils::Expressions::Functions::Operations::Logical::Or.new(
          Aws::Templates::Utils::Expressions::Functions::Operations::Range::Inside.new(
            Aws::Templates::Utils::Expressions::Variables::Arithmetic.new(:x),
            Aws::Templates::Utils::Expressions::Functions::Range.new(
              Aws::Templates::Utils::Expressions::Functions::Range::Border::Inclusive.new(1),
              Aws::Templates::Utils::Expressions::Functions::Range::Border::Exclusive.new(2)
            )
          ),
          Aws::Templates::Utils::Expressions::Functions::Operations::Comparisons::Greater.new(
            Aws::Templates::Utils::Expressions::Variables::Arithmetic.new(:y),
            Aws::Templates::Utils::Expressions::Number.new(1)
          )
        )
      end

      it_behaves_like 'operation'
    end
  end

  describe 'arithmetic' do
    describe '+' do
      let(:dsl_expression) do
        dsl.expression { x + y + 1 }
      end

      let(:parsed_expression) do
        parser.parse('x + y + 1')
      end

      let(:expected) do
        Aws::Templates::Utils::Expressions::Functions::Operations::Arithmetic::Addition.new(
          Aws::Templates::Utils::Expressions::Functions::Operations::Arithmetic::Addition.new(
            Aws::Templates::Utils::Expressions::Variables::Arithmetic.new(:x),
            Aws::Templates::Utils::Expressions::Variables::Arithmetic.new(:y)
          ),
          1
        )
      end

      it_behaves_like 'operation'
    end

    describe '-' do
      let(:dsl_expression) do
        dsl.expression { x - y - 1 }
      end

      let(:parsed_expression) do
        parser.parse('x - y - 1')
      end

      let(:expected) do
        Aws::Templates::Utils::Expressions::Functions::Operations::Arithmetic::Subtraction.new(
          Aws::Templates::Utils::Expressions::Functions::Operations::Arithmetic::Subtraction.new(
            Aws::Templates::Utils::Expressions::Variables::Arithmetic.new(:x),
            Aws::Templates::Utils::Expressions::Variables::Arithmetic.new(:y)
          ),
          1
        )
      end

      it_behaves_like 'operation'
    end

    describe '*' do
      let(:dsl_expression) do
        dsl.expression { x * y * 2 }
      end

      let(:parsed_expression) do
        parser.parse('x * y * 2')
      end

      let(:expected) do
        Aws::Templates::Utils::Expressions::Functions::Operations::Arithmetic::Multiplication.new(
          Aws::Templates::Utils::Expressions::Functions::Operations::Arithmetic::Multiplication.new(
            Aws::Templates::Utils::Expressions::Variables::Arithmetic.new(:x),
            Aws::Templates::Utils::Expressions::Variables::Arithmetic.new(:y)
          ),
          2
        )
      end

      it_behaves_like 'operation'
    end

    describe '/' do
      let(:dsl_expression) do
        dsl.expression { x / y / 2 }
      end

      let(:parsed_expression) do
        parser.parse('x / y / 2')
      end

      let(:expected) do
        Aws::Templates::Utils::Expressions::Functions::Operations::Arithmetic::Division.new(
          Aws::Templates::Utils::Expressions::Functions::Operations::Arithmetic::Division.new(
            Aws::Templates::Utils::Expressions::Variables::Arithmetic.new(:x),
            Aws::Templates::Utils::Expressions::Variables::Arithmetic.new(:y)
          ),
          2
        )
      end

      it_behaves_like 'operation'
    end

    describe 'combined' do
      let(:dsl_expression) do
        dsl.expression { x / y * 2 + 1 / z > 5 + z / 3 * 100 }
      end

      let(:parsed_expression) do
        parser.parse('x / y * 2 + 1 / z > 5 + z / 3 * 100')
      end

      let(:expected) do
        left = Aws::Templates::Utils::Expressions::Functions::Operations::Arithmetic::Addition.new(
          Aws::Templates::Utils::Expressions::Functions::Operations::Arithmetic::Multiplication.new(
            Aws::Templates::Utils::Expressions::Functions::Operations::Arithmetic::Division.new(
              Aws::Templates::Utils::Expressions::Variables::Arithmetic.new(:x),
              Aws::Templates::Utils::Expressions::Variables::Arithmetic.new(:y)
            ),
            2
          ),
          Aws::Templates::Utils::Expressions::Functions::Operations::Arithmetic::Division.new(
            1,
            Aws::Templates::Utils::Expressions::Variables::Arithmetic.new(:z)
          )
        )

        Aws::Templates::Utils::Expressions::Functions::Operations::Comparisons::Greater.new(
          left,
          Aws::Templates::Utils::Expressions::Functions::Operations::Arithmetic::Multiplication.new(
            Aws::Templates::Utils::Expressions::Functions::Operations::Arithmetic::Division.new(
              Aws::Templates::Utils::Expressions::Variables::Arithmetic.new(:z),
              3
            ),
            100
          )
        )
      end

      it_behaves_like 'operation'
    end
  end
end
