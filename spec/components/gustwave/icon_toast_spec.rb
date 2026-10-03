require "rails_helper"

RSpec.describe Gustwave::IconToast, type: :component do
  it "labels the icon with the translated scheme" do
    render_inline(described_class.new("Saved", scheme: :success))

    expect(rendered_content).to have_selector("span.sr-only", text: "Erfolg")
  end

  it "labels the icon in English" do
    I18n.with_locale(:en) { render_inline(described_class.new("Oops", scheme: :error)) }

    expect(rendered_content).to have_selector("span.sr-only", text: "Error")
  end

  it "renders an empty label without a scheme" do
    render_inline(described_class.new("Plain", scheme: :none))

    expect(rendered_content).to have_selector("span.sr-only", text: "", exact_text: true, visible: :all)
  end
end
