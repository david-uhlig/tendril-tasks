require "rails_helper"

RSpec.describe Gustwave::Form::RichText::Divider, type: :component do
  context "with default options" do
    before(:context) do
      render_inline(described_class.new)
    end

    it "renders a separator role" do
      expect(rendered_content).to have_selector("div[role='separator']")
    end

    it "renders a vertical orientation" do
      expect(rendered_content).to have_selector("div[role='separator'][aria-orientation='vertical']")
    end
  end
end
