require 'spec_helper'

describe Aws::Templates::Utils::Expressions::Functions::Operations do
  let(:expressions) do
    Aws::Templates::Utils::Expressions
  end

  let(:definition) do
    expressions::Definition.new do
      var x: Aws::Templates::Utils::Expressions::Variables::Arithmetic,
          y: Aws::Templates::Utils::Expressions::Variables::Arithmetic,
          z: Aws::Templates::Utils::Expressions::Variables::Arithmetic

      var a: Aws::Templates::Utils::Expressions::Variables::Logical,
          b: Aws::Templates::Utils::Expressions::Variables::Logical,
          c: Aws::Templates::Utils::Expressions::Variables::Logical
    end
  end

  let(:dsl) do
    expressions::Dsl.new(definition)
  end

  let(:parser) do
    expressions::Parser.with(definition)
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
        expressions::Functions::Operations::Logical::And.new(
          definition,
          expressions::Functions::Operations::Logical::And.new(
            definition,
            expressions::Variables::Logical.new(definition, :a),
            expressions::Variables::Logical.new(definition, :b)
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
        expressions::Functions::Operations::Logical::Not.new(
          definition,
          expressions::Variables::Logical.new(definition, :a)
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
        expressions::Functions::Operations::Logical::Or.new(
          definition,
          expressions::Functions::Operations::Logical::Or.new(
            definition,
            expressions::Variables::Logical.new(definition, :a),
            expressions::Variables::Logical.new(definition, :b)
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
        expressions::Functions::Operations::Logical::Or.new(
          definition,
          expressions::Functions::Operations::Logical::Or.new(
            definition,
            expressions::Variables::Logical.new(definition, :a),
            expressions::Variables::Logical.new(definition, :b)
          ),
          expressions::Functions::Operations::Logical::And.new(
            definition,
            expressions::Functions::Operations::Logical::And.new(
              definition,
              expressions::Functions::Operations::Logical::Not.new(
                definition,
                expressions::Variables::Logical.new(definition, :c)
              ),
              expressions::Variables::Logical.new(definition, :a)
            ),
            expressions::Functions::Operations::Logical::Or.new(
              definition,
              expressions::Variables::Logical.new(definition, :b),
              expressions::Variables::Logical.new(definition, :c)
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
        expressions::Functions::Operations::Comparisons::Greater.new(
          definition,
          expressions::Variables::Arithmetic.new(definition, :x),
          expressions::Number.new(definition, 1)
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
        expressions::Functions::Operations::Comparisons::Less.new(
          definition,
          expressions::Variables::Arithmetic.new(definition, :x),
          expressions::Number.new(definition, 1)
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
        expressions::Functions::Operations::Comparisons::GreaterOrEqual.new(
          definition,
          expressions::Variables::Arithmetic.new(definition, :x),
          expressions::Number.new(definition, 1)
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
        expressions::Functions::Operations::Comparisons::LessOrEqual.new(
          definition,
          expressions::Variables::Arithmetic.new(definition, :x),
          expressions::Number.new(definition, 1)
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
        expressions::Functions::Operations::Comparisons::NotEqual.new(
          definition,
          expressions::Variables::Arithmetic.new(definition, :x),
          expressions::Number.new(definition, 1)
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
        expressions::Functions::Operations::Range::Outside.new(
          definition,
          expressions::Variables::Arithmetic.new(definition, :x),
          expressions::Functions::Range.new(
            definition,
            expressions::Functions::Range::Border::Inclusive.new(
              definition, 1
            ),
            expressions::Functions::Range::Border::Exclusive.new(
              definition, 2
            )
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
        expressions::Functions::Operations::Range::Inside.new(
          definition,
          expressions::Variables::Arithmetic.new(definition, :x),
          expressions::Functions::Range.new(
            definition,
            expressions::Functions::Range::Border::Inclusive.new(
              definition, 1
            ),
            expressions::Functions::Range::Border::Exclusive.new(
              definition,
              2
            )
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
        expressions::Functions::Operations::Logical::Or.new(
          definition,
          expressions::Functions::Operations::Range::Inside.new(
            definition,
            expressions::Variables::Arithmetic.new(definition, :x),
            expressions::Functions::Range.new(
              definition,
              expressions::Functions::Range::Border::Inclusive.new(
                definition, 1
              ),
              expressions::Functions::Range::Border::Exclusive.new(
                definition, 2
              )
            )
          ),
          expressions::Functions::Operations::Comparisons::Greater.new(
            definition,
            expressions::Variables::Arithmetic.new(definition, :y),
            expressions::Number.new(definition, 1)
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
        expressions::Functions::Operations::Arithmetic::Addition.new(
          definition,
          expressions::Functions::Operations::Arithmetic::Addition.new(
            definition,
            expressions::Variables::Arithmetic.new(definition, :x),
            expressions::Variables::Arithmetic.new(definition, :y)
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
        expressions::Functions::Operations::Arithmetic::Subtraction.new(
          definition,
          expressions::Functions::Operations::Arithmetic::Subtraction.new(
            definition,
            expressions::Variables::Arithmetic.new(definition, :x),
            expressions::Variables::Arithmetic.new(definition, :y)
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
        expressions::Functions::Operations::Arithmetic::Multiplication.new(
          definition,
          expressions::Functions::Operations::Arithmetic::Multiplication.new(
            definition,
            expressions::Variables::Arithmetic.new(definition, :x),
            expressions::Variables::Arithmetic.new(definition, :y)
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
        expressions::Functions::Operations::Arithmetic::Division.new(
          definition,
          expressions::Functions::Operations::Arithmetic::Division.new(
            definition,
            expressions::Variables::Arithmetic.new(definition, :x),
            expressions::Variables::Arithmetic.new(definition, :y)
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
        left = expressions::Functions::Operations::Arithmetic::Addition.new(
          definition,
          expressions::Functions::Operations::Arithmetic::Multiplication.new(
            definition,
            expressions::Functions::Operations::Arithmetic::Division.new(
              definition,
              expressions::Variables::Arithmetic.new(definition, :x),
              expressions::Variables::Arithmetic.new(definition, :y)
            ),
            2
          ),
          expressions::Functions::Operations::Arithmetic::Division.new(
            definition,
            1,
            expressions::Variables::Arithmetic.new(definition, :z)
          )
        )

        expressions::Functions::Operations::Comparisons::Greater.new(
          definition,
          left,
          expressions::Functions::Operations::Arithmetic::Addition.new(
            definition,
            5,
            expressions::Functions::Operations::Arithmetic::Multiplication.new(
              definition,
              expressions::Functions::Operations::Arithmetic::Division.new(
                definition,
                expressions::Variables::Arithmetic.new(definition, :z),
                3
              ),
              100
            )
          )
        )
      end

      it_behaves_like 'operation'
    end
  end
end
