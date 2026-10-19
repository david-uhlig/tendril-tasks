# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::Form::RichText::Trix::Toolbar, type: :component do
  def toolbar
    page.find("trix-toolbar")
  end

  it "renders a trix-toolbar with the given id" do
    render_inline(described_class.new(nil, id: "my-toolbar"))

    expect(toolbar["id"]).to eq("my-toolbar")
  end

  it "generates a unique id for each toolbar without an id" do
    ids = 2.times.map do
      render_inline(described_class.new(nil))
      toolbar["id"]
    end

    expect(ids).to all(start_with("toolbar-"))
    expect(ids.uniq.size).to eq(2)
  end

  it "passes HTML attributes to the surrounding element" do
    render_inline(described_class.new(nil, class: "my-toolbar", data: { test: "toolbar" }))

    expect(page).to have_css("div.my-toolbar[data-test='toolbar'] > trix-toolbar")
  end

  describe "default rendering" do
    before do
      render_inline(described_class.new(nil))
    end

    it "renders a button for each formatting action" do
      %w[bold italic strike heading1 heading6 quote code bullet number].each do |attribute|
        expect(toolbar).to have_css("button[data-trix-attribute='#{attribute}']")
      end
    end

    it "renders a button for each nesting and file action" do
      %w[attachFiles increaseNestingLevel decreaseNestingLevel].each do |action|
        expect(toolbar).to have_css("button[data-trix-action='#{action}']")
      end
    end

    it "renders the keyboard shortcut Trix listens to for a formatting action" do
      expect(toolbar).to have_css("button[data-trix-attribute='bold'][data-trix-key='b']")
    end

    it "renders the undo and redo actions" do
      expect(toolbar).to have_css("button[data-trix-action='undo'][data-trix-key='z']")
      expect(toolbar).to have_css("button[data-trix-action='redo'][data-trix-key='shift+z']")
    end

    it "renders the link toggle as a dialog trigger for the href attribute" do
      expect(toolbar).to have_css("button[data-trix-attribute='href'][data-trix-key='k']")
      expect(toolbar).to have_css("[data-trix-dialog='href'][data-trix-dialog-attribute='href']", visible: :all)
    end

    it "renders a divider between each group of actions" do
      expect(toolbar).to have_css("div.px-1", count: 4)
    end
  end

  context "with hidden actions" do
    before do
      render_inline(described_class.new(nil, hidden: %i[italic link heading1 heading2 heading3 heading4 heading5 heading6]))
    end

    it "does not render a hidden action" do
      expect(toolbar).to have_no_css("button[data-trix-attribute='italic']")
    end

    it "does not render the hidden link toggle" do
      expect(toolbar).to have_no_css("[data-trix-dialog='href']", visible: :all)
    end

    it "keeps the actions that are not hidden" do
      expect(toolbar).to have_css("button[data-trix-attribute='bold']")
    end

    it "does not render a divider for a group whose actions are all hidden" do
      expect(toolbar).to have_css("div.px-1", count: 3)
    end
  end

  context "with disabled actions" do
    before do
      render_inline(described_class.new(nil, disabled: %i[heading2 link]))
    end

    it "renders a disabled button for a disabled action" do
      expect(toolbar).to have_css("button[disabled]", text: "H2")
    end

    it "does not render the Trix attributes of a disabled action" do
      expect(toolbar).to have_no_css("[data-trix-attribute='heading2']")
    end

    it "renders the link toggle as a disabled button" do
      expect(toolbar).to have_css("button[disabled][data-popover-target]")
    end

    it "does not render the Trix attributes of the disabled link toggle" do
      expect(toolbar).to have_no_css("button[data-trix-attribute='href']")
    end

    it "keeps the other heading buttons enabled" do
      expect(toolbar).to have_css("button[data-trix-attribute='heading3']:not([disabled])")
    end
  end
end
