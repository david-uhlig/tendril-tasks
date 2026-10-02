# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::Form::RichText::Lexxy::Toolbar, type: :component do
  def toolbar
    page.find("lexxy-toolbar")
  end

  describe "default rendering" do
    before do
      render_inline(described_class.new(id: "my-toolbar"))
    end

    it "renders a lexxy-toolbar with the given id" do
      expect(toolbar["id"]).to eq("my-toolbar")
    end

    it "connects the heading controller" do
      expect(toolbar["data-controller"]).to eq("lexxy-heading")
    end

    it "renders a button for each command" do
      %w[ bold italic strikethrough underline applyHeadingFormat insertQuoteBlock
          insertCodeBlock insertUnorderedList insertOrderedList insertTable
          insertHorizontalDivider uploadFile undo redo ].each do |command|
        expect(toolbar).to have_css("button[data-command='#{command}']")
      end
    end

    it "renders the heading buttons as targets of the heading controller" do
      expect(toolbar).to have_css("button[data-lexxy-heading-target='button']", count: 3)
      expect(toolbar).to have_css("button[data-payload='h2']")
      expect(toolbar).to have_css("button[data-payload='h4']")
    end

    it "renders the link dropdown" do
      expect(toolbar).to have_css("lexxy-link-dropdown button[data-dropdown-trigger][name='link']")
      expect(toolbar).to have_css("lexxy-link-dropdown [data-dropdown-panel] input[type='url']", visible: :all)
      expect(toolbar).to have_css("lexxy-link-dropdown button[value='link']", visible: :all)
      expect(toolbar).to have_css("lexxy-link-dropdown button[value='unlink']", visible: :all)
    end

    it "renders the highlight dropdown" do
      expect(toolbar).to have_css("lexxy-highlight-dropdown button[data-dropdown-trigger][name='highlight']")
      expect(toolbar).to have_css("lexxy-highlight-dropdown .lexxy-highlight-colors", visible: :all)
      expect(toolbar).to have_css("lexxy-highlight-dropdown button[data-command='removeHighlight']", visible: :all)
    end

    it "renders the overflow menu Lexxy requires" do
      expect(toolbar).to have_css(".lexxy-editor__toolbar-overflow [data-dropdown-panel]", visible: :all)
    end
  end

  context "with hidden actions" do
    before do
      render_inline(described_class.new(hidden: %i[table horizontal_rule link]))
    end

    it "does not render the hidden actions" do
      expect(toolbar).to have_no_css("button[data-command='insertTable']")
      expect(toolbar).to have_no_css("button[data-command='insertHorizontalDivider']")
      expect(toolbar).to have_no_css("lexxy-link-dropdown")
    end

    it "does not render a divider for an empty group" do
      render_inline(described_class.new(hidden: %i[table horizontal_rule]))
      dividers = page.all("lexxy-toolbar > div.px-1").count

      render_inline(described_class.new)
      expect(page.all("lexxy-toolbar > div.px-1").count).to eq(dividers + 1)
    end
  end

  context "with disabled actions" do
    before do
      render_inline(described_class.new(disabled: %i[heading2 link]))
    end

    it "renders the disabled buttons without a command" do
      expect(toolbar).to have_css("button[name='heading2'][disabled]:not([data-command])")
    end

    it "renders a disabled link trigger" do
      expect(toolbar).to have_css("button[name='link'][disabled]")
    end

    it "keeps the other heading buttons enabled" do
      expect(toolbar).to have_css("button[name='heading3']:not([disabled])")
    end
  end
end
