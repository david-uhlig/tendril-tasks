# Dropdown triggers own +data-dropdown-toggle+ and +aria-controls+. A caller's
# copies of them, in any spelling, are dropped, so each renders once with the
# menu id. Duplicates are counted in the raw HTML because Nokogiri keeps only
# one of two identical attributes.
RSpec.shared_examples "a dropdown trigger owning its attributes" do
  def render_trigger(**options)
    render_inline(described_class.new(menu_id: "menu", **options)) { "content" }
  end

  {
    "a flat aria-controls" => [ { "aria-controls": "other" }, "aria-controls" ],
    "a string aria-controls" => [ { "aria-controls" => "other" }, "aria-controls" ],
    "aria: { controls: }" => [ { aria: { controls: "other" } }, "aria-controls" ],
    "a flat data-dropdown-toggle" => [ { "data-dropdown-toggle": "z" }, "data-dropdown-toggle" ],
    "data: { dropdown_toggle: }" => [ { data: { dropdown_toggle: "x" } }, "data-dropdown-toggle" ],
    "data: { \"dropdown-toggle\": }" => [ { data: { "dropdown-toggle": "y" } }, "data-dropdown-toggle" ]
  }.each do |input, (options, attribute)|
    it "renders #{attribute} once, with the menu, for #{input}" do
      render_trigger(**options)

      expect(rendered_content.scan(/#{Regexp.escape(attribute)}=/).size).to eq(1)
      expect(rendered_content).to include(%(#{attribute}="menu"))
    end
  end

  it "keeps the caller's other data next to the dropdown's attributes" do
    render_trigger(data: { controller: "c", dropdown_toggle: "x" })

    expect(rendered_content).to include('data-controller="c"')
    expect(rendered_content.scan(/data-dropdown-toggle=/).size).to eq(1)
    expect(rendered_content).to include('data-dropdown-toggle="menu"')
  end

  it "keeps the caller's other dropdown-prefixed data, e.g. a Stimulus target" do
    render_trigger(data: { dropdown_keyboard_target: "trigger" }, "data-dropdown-keyboard-action": "x")

    expect(rendered_content).to include('data-dropdown-keyboard-target="trigger"')
    expect(rendered_content).to include('data-dropdown-keyboard-action="x"')
  end

  it "drops the caller's copy of an option-backed attribute" do
    render_trigger(delay: 500, data: { dropdown_delay: 100 })

    expect(rendered_content.scan(/data-dropdown-delay=/).size).to eq(1)
    expect(rendered_content).to include('data-dropdown-delay="500"')
  end

  it "keeps the caller's other aria attributes next to aria-controls" do
    render_trigger(aria: { label: "x", controls: "other" })

    expect(rendered_content).to include('aria-label="x"')
    expect(rendered_content.scan(/aria-controls=/).size).to eq(1)
    expect(rendered_content).to include('aria-controls="menu"')
  end
end
