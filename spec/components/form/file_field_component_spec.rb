# frozen_string_literal: true

require "rails_helper"

RSpec.describe Form::FileFieldComponent, type: :component do
  let(:form) { ActionView::Helpers::FormBuilder.new(:site, nil, ActionView::Base.empty, {}) }

  it "renders the file input" do
    render_inline(described_class.new(form, :logo, "Logo"))

    expect(page).to have_selector("input[type='file'][name='site[logo]']")
  end

  context "with helper_text" do
    before do
      render_inline(described_class.new(form, :logo, "Logo")) do |field|
        field.with_helper_text("PNG or SVG, max. 2 MB")
      end
    end

    it "renders the text in a paragraph" do
      expect(page).to have_selector("p", text: "PNG or SVG, max. 2 MB")
    end
  end

  it "passes id and class options to the helper text paragraph" do
    render_inline(described_class.new(form, :logo, "Logo")) do |field|
      field.with_helper_text("Help", id: "logo-help", class: "custom-class")
    end

    expect(page).to have_selector("p#logo-help.custom-class", text: "Help")
  end

  it "renders no paragraph without helper_text" do
    render_inline(described_class.new(form, :logo, "Logo"))

    expect(page).to have_no_selector("p")
  end

  context "when the attribute has errors" do
    let(:site) { Site.new }
    let(:form) { ActionView::Helpers::FormBuilder.new(:site, site, ActionView::Base.empty, {}) }

    before do
      site.errors.add(:logo, "is too large")
      render_inline(described_class.new(form, :logo, "Logo"))
    end

    it "marks the input as invalid and points it at the error message" do
      expect(page).to have_selector("input[type='file'][aria-invalid='true'][aria-describedby='error-message-for-logo']")
    end
  end
end
