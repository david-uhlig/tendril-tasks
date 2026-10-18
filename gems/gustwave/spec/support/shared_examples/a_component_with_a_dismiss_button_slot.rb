# Components with a +dismiss_button+ slot render a Gustwave::DismissButton that
# dismisses the component. Its +data+ and +aria+ attributes keep the defaults
# when the caller adds to them.
#
# @param args [Array] arguments to pass to the component constructor
# @param id_prefix [String] prefix of the id the component generates, e.g. "badge"
# @param kwargs [Hash] additional keyword arguments to pass to the component constructor
RSpec.shared_examples "a component with a dismiss button slot" do |*args, id_prefix:, **kwargs|
  it "renders a button dismissing the component by its generated id" do
    render_inline(described_class.new(*args, **kwargs), &:with_dismiss_button)

    id = page.find("[id^='#{id_prefix}-']")[:id]
    expect(page).to have_selector("button[data-dismiss-target='##{id}']")
  end

  it "renders a button dismissing the component by a given id" do
    render_inline(described_class.new(*args, **kwargs, id: "given-id"), &:with_dismiss_button)

    expect(page).to have_selector("#given-id > button[data-dismiss-target='#given-id']")
  end

  it "labels the button and its screen reader text as dismissing" do
    I18n.with_locale(:en) { render_inline(described_class.new(*args, **kwargs), &:with_dismiss_button) }

    expect(page).to have_selector("button[aria-label='Dismiss'] > span.sr-only", text: "Dismiss")
  end

  it "localizes the default label" do
    I18n.with_locale(:de) { render_inline(described_class.new(*args, **kwargs), &:with_dismiss_button) }

    expect(page).to have_selector("button[aria-label='Schließen'] > span.sr-only", text: "Schließen")
  end

  it "uses the text as label and screen reader text" do
    render_inline(described_class.new(*args, **kwargs)) { |component| component.with_dismiss_button("Remove filter") }

    expect(page).to have_selector("button[aria-label='Remove filter'] > span.sr-only", text: "Remove filter")
  end

  it "renders block content without sr-only markup" do
    render_inline(described_class.new(*args, **kwargs)) { |component| component.with_dismiss_button { "Got it" } }

    expect(page).to have_selector("button", text: "Got it")
    expect(page).not_to have_selector("button span.sr-only")
  end

  it "keeps the dismiss target when the caller adds data" do
    render_inline(described_class.new(*args, **kwargs)) { |component| component.with_dismiss_button(data: { foo: "1" }) }

    expect(page).to have_selector("button[data-foo='1'][data-dismiss-target^='##{id_prefix}-']")
  end

  it "keeps the label when the caller adds aria attributes" do
    render_inline(described_class.new(*args, **kwargs)) { |component| component.with_dismiss_button(aria: { describedby: "hint" }) }

    expect(page).to have_selector("button[aria-label='Dismiss'][aria-describedby='hint']")
  end
end
