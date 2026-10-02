# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::Form::RichText::Lexxy::Button, type: :component do
  def button
    page.find("button")
  end

  it "renders the command for a formatting action" do
    render_inline(described_class.new(:bold))

    expect(button["data-command"]).to eq("bold")
    expect(button["name"]).to eq("bold")
  end

  it "renders the name Lexxy uses to track the button state" do
    render_inline(described_class.new(:bullet))

    expect(button["data-command"]).to eq("insertUnorderedList")
    expect(button["name"]).to eq("unordered-list")
  end

  it "renders the heading tag as the command payload" do
    render_inline(described_class.new(:heading3))

    expect(button["data-command"]).to eq("applyHeadingFormat")
    expect(button["data-payload"]).to eq("h3")
  end

  it "renders the text of a heading action" do
    render_inline(described_class.new(:heading2))

    expect(button).to have_text("H2")
  end

  it "renders an icon for an icon action" do
    render_inline(described_class.new(:table))

    expect(button).to have_css("svg")
    expect(button["data-command"]).to eq("insertTable")
  end

  it "renders a horizontal rule action as Lexxy's divider" do
    render_inline(described_class.new(:horizontal_rule))

    expect(button["data-command"]).to eq("insertHorizontalDivider")
    expect(button["name"]).to eq("divider")
  end

  it "renders the file upload command for attachments" do
    render_inline(described_class.new(:attach_files))

    expect(button["data-command"]).to eq("uploadFile")
  end

  context "when disabled" do
    before do
      render_inline(described_class.new(:heading2, disabled: true))
    end

    it "renders a disabled button" do
      expect(button).to be_disabled
    end

    it "does not render a command" do
      expect(button["data-command"]).to be_nil
      expect(button["data-payload"]).to be_nil
    end
  end
end
