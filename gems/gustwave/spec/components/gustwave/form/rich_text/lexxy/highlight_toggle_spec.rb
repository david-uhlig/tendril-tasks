require "rails_helper"

RSpec.describe Gustwave::Form::RichText::Lexxy::HighlightToggle, type: :component do
  context "with the en locale" do
    around { |example| I18n.with_locale(:en) { example.run } }

    before { render_inline(described_class.new) }

    it "renders the trigger as a menu popup" do
      expect(page).to have_css("lexxy-highlight-dropdown > button[name='highlight'][aria-haspopup='menu']")
    end

    it "renders the trigger collapsed" do
      expect(page).to have_css("button[name='highlight'][aria-expanded='false']")
    end

    it "labels the menu" do
      expect(page).to have_css("div[role='menu'][aria-label='Color highlight']", visible: :all)
    end

    it "renders the remove action as a menu item" do
      expect(page).to have_css("button[role='menuitem'][data-command='removeHighlight']", text: "Remove all coloring", visible: :all)
    end
  end

  context "with the de locale" do
    around { |example| I18n.with_locale(:de) { example.run } }

    before { render_inline(described_class.new) }

    it "translates the menu label" do
      expect(page).to have_css("div[role='menu'][aria-label='Farbig hervorheben']", visible: :all)
    end

    it "translates the remove action" do
      expect(page).to have_css("button[role='menuitem']", text: "Farben entfernen", visible: :all)
    end
  end
end
