# A button theme renders a button with its content. Its default color is a
# color of its own, not +:none+, and every color it declares renders its own
# classes. The colors come from the theme's declared values, so the example
# doesn't list any class.
RSpec.shared_examples "a button theme" do
  def button_class_for(**options)
    render_inline(described_class.new("Go", **options))
    page.find("button")["class"]
  end

  it "renders a button with its content" do
    render_inline(described_class.new("Go"))

    expect(page).to have_selector("button", text: "Go")
  end

  it "renders its default color differently from :none" do
    expect(button_class_for).not_to eq(button_class_for(color: :none))
  end

  it "renders distinct classes for every color" do
    classes = described_class.option_values(:color).map { |color| button_class_for(color:) }

    expect(classes.uniq.size).to eq(classes.size)
  end
end
