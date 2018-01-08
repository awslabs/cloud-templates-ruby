require 'spec_helper'
require 'aws/templates/utils'

describe Aws::Templates::Help::Rdoc::Artifact do
  let(:klass) do
    Class.new(Aws::Templates::Artifact) do
      help 'Very good thing'

      def self.name
        'Test'
      end

      default undocumented: 3,
              label: :ert,
              root: :a

      default :ancestors.to_proc

      default a: { b: :name.to_proc }

      default a: { b: { d: 1 } }

      parameter :undocumented
      parameter :undocumented_with_constraint, constraint: not_nil
      parameter :undocumented_with_constraint_and_transform,
                constraint: not_nil,
                transform: as_string
      parameter :documented,
                description: 'Documented parameter'
      parameter :documented_with_constraint,
                description: 'Documented parameter with constraint',
                constraint: enum(1, 2, 3)
      parameter :documented_with_constraint_and_transform,
                description: 'Documented parameter with constraint and transformation',
                constraint: all_of(
                  not_nil,
                  satisfies('not too big') { |v| v.size < 10 }
                ),
                transform: as_list
    end
  end

  let(:help) { Aws::Templates::Help::Rdoc.show(klass) }

  let(:blurb) do
    "\e[0m  \n" \
    "\e[1mTest\e[m\n" \
    "  \e[4mParents\e[m: Aws::Templates::Artifact\n\n" \
    "  \e[4mDescription\e[m\n" \
    "    Very good thing\n\n\n" \
    "  \e[4mParameters\e[m\n" \
    "  * \e[4mlabel\e[m Artifact's label\n" \
    "    * constraint:\n" \
    "      * can't be nil\n" \
    "  * \e[4mparent\e[m Artifact parent\n" \
    "  * \e[4mundocumented\e[m \n" \
    "  * \e[4mundocumented_with_constraint\e[m \n" \
    "    * constraint:\n" \
    "      * can't be nil\n" \
    "  * \e[4mundocumented_with_constraint_and_transform\e[m \n" \
    "    * transformation:\n" \
    "      * to string\n" \
    "    * constraint:\n" \
    "      * can't be nil\n" \
    "  * \e[4mdocumented\e[m Documented parameter\n" \
    "  * \e[4mdocumented_with_constraint\e[m Documented parameter with constraint\n" \
    "    * constraint:\n" \
    "      * one of: 1,2,3\n" \
    "  * \e[4mdocumented_with_constraint_and_transform\e[m Documented parameter with\n" \
    "    constraint and transformation\n" \
    "    * transformation:\n" \
    "      * as a list where elements can be anything\n" \
    "    * constraint:\n" \
    "      * satisfies all of the following:\n" \
    "        * can't be nil\n" \
    "        * not too big\n\n" \
    "  \e[4mDefaults\e[m\n" \
    "    * \e[4mlabel\e[m :ert\n" \
    "    * \e[4mroot\e[m :a\n" \
    "    * \e[4mundocumented\e[m 3\n" \
    "    \e[4moverlayed\e[m \e[4mwith\e[m\n" \
    "    Calculated\n" \
    "    \e[4moverlayed\e[m \e[4mwith\e[m\n" \
    "    * \e[4ma\e[m\n" \
    "      * \e[4mb\e[m Calculated\n" \
    "        \e[4moverlayed\e[m \e[4mwith\e[m\n" \
    "        \e[4mb\e[m\n" \
    "        * \e[4md\e[m 1\n\n\n"
  end

  it 'generates help correctly' do
    expect(help).to be == blurb
  end
end
