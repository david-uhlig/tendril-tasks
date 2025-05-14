# Components that render content should consistently provide the following
# interface:
# - Accept an optional text parameter in the first position of the parameter list
# - Accept a block yielded to the component
# - Render only the text parameter when both text and block content are provided
#
# @param args [Array] additional arguments to pass to the component constructor
# @param selector [String] CSS selector to use when checking for rendered content (e.g. "button", "div", "div>span")
# @param text [String] sample text to use for text content tests (default "text_content")
# @param block_content [String] sample text to use for block content tests (default "block_content")
# @param component_class [Class] component class to test (default `described_class`)
# @param kwargs [Hash] additional keyword arguments to pass to the component constructor
RSpec.shared_examples "a text and block content renderer" do |*args, selector:, text: "text_content", block_content: "block_content", component_class: described_class, **kwargs|
  it "renders text content" do
    render_inline(component_class.new(text, *args, **kwargs))
    expect(rendered_content).to have_selector(selector, text: text)
  end

  it "renders block content" do
    render_inline(component_class.new(*args, **kwargs)) { block_content }
    expect(rendered_content).to have_selector(selector, text: block_content)
  end

  it "renders text over block content" do
    render_inline(component_class.new(text, *args, **kwargs)) { block_content }
    expect(rendered_content).to have_selector(selector, text: text)
    expect(rendered_content).not_to have_selector(selector, text: block_content)
  end
end
