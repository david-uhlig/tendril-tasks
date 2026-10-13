# Components should pass through html attributes to the rendered html element.
# The class attribute should be merged semantically with TailwindMerge.
#
# @param args [Array] additional arguments to pass to the component constructor
# @param selector [String] CSS selector to use when checking for rendered content (e.g. "button", "div", "div>span")
# @param id [String] sample id to use for id attribute tests (default "some-id-for-this-component")
# @param name [String] sample name to use for name attribute tests (default "The component under test")
# @param classes [String] sample classes to use for class attribute tests (default "bg-white some-additional-class")
# @param component_class [Class] component class to test (default `described_class`)
# @param kwargs [Hash] additional keyword arguments to pass to the component constructor
RSpec.shared_examples "a component with configurable html attributes" do |*args, selector:, id: "some-id-for-this-component", name: "The component under test", classes: "bg-white some-additional-class", component_class: described_class, **kwargs|
  before(:context) do
    render_inline(component_class.new(*args, id:, name:, class: classes, **kwargs)) { "content" }
  end

  it "renders the id attribute" do
    expect(rendered_content).to have_selector("#{selector}[id='#{id}']")
  end

  it "renders the name attribute" do
    expect(rendered_content).to have_selector("#{selector}[name='#{name}']")
  end

  it "renders the class attributes" do
    expect(rendered_content).to have_selector("#{selector}.#{classes.split.join('.')}")
  end
end
