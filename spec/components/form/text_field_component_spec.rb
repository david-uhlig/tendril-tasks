# frozen_string_literal: true

require "rails_helper"

RSpec.describe Form::TextFieldComponent, type: :component do
  let(:site) { Site.new }
  let(:form) { ActionView::Helpers::FormBuilder.new(:site, site, ActionView::Base.empty, {}) }

  context "when the attribute has errors" do
    before do
      site.errors.add(:name, :blank)
      render_inline(described_class.new(form, :name))
    end

    it "marks the input as invalid" do
      expect(page).to have_selector("input[name='site[name]'][aria-invalid='true']")
    end

    it "points the input at its error message" do
      expect(page).to have_selector("input[name='site[name]'][aria-describedby='error-message-for-name']")
      expect(page).to have_selector("span#error-message-for-name", text: site.errors[:name].first)
    end

    it "keeps the description the caller gave" do
      render_inline(described_class.new(form, :name, aria: { describedby: "name-help" }))

      expect(page).to have_selector("input[aria-describedby='name-help error-message-for-name']")
    end
  end

  context "when the attribute has no errors" do
    before do
      render_inline(described_class.new(form, :name))
    end

    it "does not mark the input as invalid" do
      expect(page).to have_no_selector("input[aria-invalid]")
    end

    it "does not reference an error message" do
      expect(page).to have_no_selector("input[aria-describedby]")
    end
  end
end
