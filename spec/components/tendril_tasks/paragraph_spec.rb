require "rails_helper"

RSpec.describe TendrilTasks::Paragraph, type: :component do
  it "renders a large paragraph by default" do
    render_inline(described_class.new("Text"))

    expect(rendered_content).to have_selector("p.text-lg.lg\\:text-xl.text-gray-500.hyphens-auto[lang='de']", text: "Text")
  end

  it "renders a medium paragraph" do
    render_inline(described_class.new("Text", size: :md))

    expect(rendered_content).to have_selector("p.text-base.lg\\:text-lg.font-normal:not(.text-lg)", text: "Text")
  end

  it "renders a small paragraph" do
    render_inline(described_class.new("Text", size: :sm))

    expect(rendered_content).to have_selector("p.text-sm.lg\\:text-base.font-normal", text: "Text")
  end
end
