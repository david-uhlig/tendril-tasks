# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::Form::RichText::Trix::Button, type: :component do
  def button
    page.find("button")
  end

  it "renders the attribute Trix applies for a formatting action" do
    render_inline(described_class.new(:bold))

    expect(button["data-trix-attribute"]).to eq("bold")
  end

  it "renders the keyboard shortcut for a formatting action" do
    render_inline(described_class.new(:italic))

    expect(button["data-trix-key"]).to eq("i")
  end

  it "renders no action for a formatting action" do
    render_inline(described_class.new(:bold))

    expect(button["data-trix-action"]).to be_nil
  end

  it "renders the action Trix runs for undo" do
    render_inline(described_class.new(:undo))

    expect(button["data-trix-action"]).to eq("undo")
    expect(button["data-trix-key"]).to eq("z")
  end

  it "renders the nesting action Trix runs for an indent" do
    render_inline(described_class.new(:increase_nesting))

    expect(button["data-trix-action"]).to eq("increaseNestingLevel")
  end

  it "renders the file action Trix runs for attachments" do
    render_inline(described_class.new(:attach_files))

    expect(button["data-trix-action"]).to eq("attachFiles")
  end

  it "renders the text of a heading action" do
    render_inline(described_class.new(:heading2))

    expect(button).to have_text("H2")
  end

  it "renders an icon for an icon action" do
    render_inline(described_class.new(:bold))

    expect(button).to have_css("svg")
  end

  it "renders the given text instead of the default icon" do
    render_inline(described_class.new(:bold, icon_or_text: "B"))

    expect(button).to have_text("B")
    expect(button).to have_no_css("svg")
  end

  it "renders the given keyboard shortcut" do
    render_inline(described_class.new(:bold, key: "x"))

    expect(button["data-trix-key"]).to eq("x")
  end

  context "with an attribute name in another case" do
    before do
      render_inline(described_class.new("Bold"))
    end

    it "renders the attribute in lowercase" do
      expect(button["data-trix-attribute"]).to eq("bold")
    end

    it "renders the keyboard shortcut of the lowercase attribute" do
      expect(button["data-trix-key"]).to eq("b")
    end
  end

  context "with an undo attribute in another case" do
    it "renders the action of the lowercase attribute" do
      render_inline(described_class.new("Undo"))

      expect(button["data-trix-action"]).to eq("undo")
    end
  end

  context "when disabled" do
    before do
      render_inline(described_class.new(:heading2, disabled: true))
    end

    it "renders a disabled button" do
      expect(button).to be_disabled
    end

    it "does not render the Trix attributes" do
      expect(button["data-trix-attribute"]).to be_nil
      expect(button["data-trix-key"]).to be_nil
      expect(button["data-trix-action"]).to be_nil
    end
  end
end
