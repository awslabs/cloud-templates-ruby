require 'spec_helper'
require 'aws/templates/utils'

class RdocTestComposite < Aws::Templates::Composite
  help 'Very good thing'

  default undocumented: 3,
          label: 23,
          root: 56

  parameter :undocumented

  contextualize filter(:copy)
end

describe Aws::Templates::Help::Rdoc::Composite do
  let(:blurb) do
    "\e[0m  \n" \
    "\e[1mRdocTestComposite\e[m\n" \
    "  \e[4mParents\e[m: Aws::Templates::Composite->Aws::Templates::Artifact\n\n" \
    "  \e[4mDescription\e[m\n" \
    "    Very good thing\n\n\n" \
    "  \e[4mParameters\e[m\n" \
    "  * \e[4mlabel\e[m Artifact's label\n" \
    "      * constraint:\n" \
    "        * can't be nil\n" \
    "  * \e[4mparent\e[m Artifact parent\n" \
    "  * \e[4mundocumented\e[m \n\n" \
    "  \e[4mDefaults\e[m\n" \
    "    * \e[4mlabel\e[m 23\n" \
    "    * \e[4mroot\e[m 56\n" \
    "    * \e[4mundocumented\e[m 3\n\n\n" \
    "  \e[4mComponents\e[m \e[4mscope\e[m \e[4mfilters\e[m\n" \
    "  * a chain of the following filters:\n" \
    "    * merge the following options from the parent context:\n" \
    "      * [:root]\n" \
    "    * merge the context with the following override:\n"
  end

  let(:help) { Aws::Templates::Help::Rdoc.show(RdocTestComposite) }

  it 'generates help blurb correctly' do
    expect(help.include?(blurb)).to be true
  end

  it 'generates defaults correctly' do
    expect(help).to match(/undocumented.*3/m)
  end

  it 'generates context filters' do
    expect(help).to match(/Components[^\n]+scope.*copy the entire/m)
  end
end
