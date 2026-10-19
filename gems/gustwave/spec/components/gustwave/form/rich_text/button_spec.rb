require "rails_helper"

RSpec.describe Gustwave::Form::RichText::Button, type: :component do
  it "renders the text of a text action" do
    render_inline(described_class.new(:heading2))

    expect(page).to have_css("button", text: "H2")
    expect(page).not_to have_css("svg")
  end

  it "renders the icon of an icon action" do
    render_inline(described_class.new(:bold))

    expect(page).to have_css("button > svg")
  end

  it "renders the given text instead of the icon" do
    render_inline(described_class.new(:bold, icon_or_text: "Fett"))

    expect(page).to have_css("button", text: "Fett")
    expect(page).not_to have_css("svg")
  end

  it "keeps the button out of the tab order" do
    render_inline(described_class.new(:bold))

    expect(page).to have_css("button[tabindex='-1']")
  end

  it "renders a disabled button" do
    render_inline(described_class.new(:bold, disabled: true))

    expect(page).to have_css("button[disabled]")
  end

  it "renders no disabled attribute when not disabled" do
    render_inline(described_class.new(:bold, disabled: false))

    expect(page).not_to have_css("button[disabled]")
  end

  it "renders the button of the given theme" do
    render_inline(described_class.new(:heading2, theme: :inline))

    expect(page).to have_css("button.text-xs")
    expect(page).not_to have_css("button.h-10")
  end
end
