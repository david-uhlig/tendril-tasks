require "rails_helper"

RSpec.describe Gustwave::Form::RichText::Lexxy::LinkToggle, type: :component do
  context "with the en locale" do
    around { |example| I18n.with_locale(:en) { example.run } }

    before { render_inline(described_class.new) }

    it "renders the trigger as a dialog popup" do
      expect(page).to have_css("lexxy-link-dropdown > button[name='link'][aria-haspopup='dialog']")
    end

    it "renders the trigger collapsed" do
      expect(page).to have_css("button[name='link'][aria-expanded='false']")
    end

    it "labels the dialog" do
      expect(page).to have_css("div[role='dialog'][aria-label='Link']", visible: :all)
    end

    it "labels the URL field" do
      expect(page).to have_css("input[type='url'][aria-label='URL'][placeholder='Enter a URL…']", visible: :all)
    end

    it "renders the link and unlink actions" do
      expect(page).to have_css("button[value='link']", text: "Link", visible: :all)
      expect(page).to have_css("button[value='unlink']", text: "Unlink", visible: :all)
    end
  end

  context "with the de locale" do
    around { |example| I18n.with_locale(:de) { example.run } }

    before { render_inline(described_class.new) }

    it "translates the dialog label and the URL placeholder" do
      expect(page).to have_css("div[role='dialog'][aria-label='Verlinken']", visible: :all)
      expect(page).to have_css("input[placeholder='URL eingeben…']", visible: :all)
    end

    it "translates the unlink action" do
      expect(page).to have_css("button[value='unlink']", text: "Link entfernen", visible: :all)
    end
  end
end
