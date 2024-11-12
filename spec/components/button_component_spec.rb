# frozen_string_literal: true

require "rails_helper"

RSpec.describe ButtonComponent, type: :component do
  context "with default options" do
    before(:each) do
      render_inline(described_class.new)
    end

    it "renders default label" do
      expect(page).to have_text(described_class::DEFAULT_LABEL)
    end

    it "renders button tag with scheme" do
      expect(page).to have_selector("button.btn-default")
    end

    it "renders button tag with size css classes" do
      expect(page).to have_selector('button.px-5.py-2\.5.text-sm.font-medium')
    end

    it "renders no leading visual" do
      expect(page).not_to have_selector("img")
    end
  end

  context "with content" do
    it "renders content" do
      render_inline(described_class.new) { "content" }
      expect(page).to have_text("content")
    end
  end

  context "with options" do
    before(:each) do
      options = {
        class: "my-class and-some-other-class"
      }
      render_inline(described_class.new(**options)) { "content" }
    end

    it "renders additional css classes" do
      expect(page).to have_selector("button.my-class.and-some-other-class")
    end

    it "renders default scheme" do
      expect(page).to have_selector("button.btn-default")
    end
  end

  context "with scheme" do
    it "renders css classes mapping to the scheme" do
      render_inline(described_class.new(scheme: :yellow)) { "content" }
      expect(page).to have_selector("button.btn-yellow")
    end
  end

  context "with size" do
    it "renders css classes mapping to the size" do
      render_inline(described_class.new(size: :large)) { "content" }
      expect(page).to have_selector("button.px-5.py-3.text-base.font-medium")
    end
  end

  context "with leading visual" do
    before(:all) do
      @test_image_path = Rails.root.join("spec", "assets", "images", "for-tests.jpg").to_s
    end

    let(:with_default_options) do
      component = described_class.new { "content" }
      render_inline(component) do |c|
        c.with_leading_visual(@test_image_path)
      end
    end

    it "renders leading visual" do
      with_default_options
      expect(page).to have_selector("img[src='#{@test_image_path}']")
    end

    it "renders no content" do
      with_default_options
      expect(page).not_to have_text("content")
    end

    it "renders accessibility attributes" do
      with_default_options
      expect(page).to have_selector("img[aria-hidden='true']")
    end

    it "renders default css classes" do
      with_default_options
      expect(page).to have_selector("img.w-5.h-5.me-2")
    end

    it "renders button with inline-flex" do
      with_default_options
      expect(page).to have_selector("button.inline-flex")
    end

    it "renders alt text" do
      component = described_class.new { "content" }
      render_inline(component) do |c|
        c.with_leading_visual(@test_image_path, alt: "alt text")
      end
      expect(page).to have_selector("img[alt='alt text']")
    end

    it "renders additional css classes" do
      component = described_class.new { "content" }
      render_inline(component) do |c|
        c.with_leading_visual(@test_image_path, class: "my-class some-other-class")
      end
      expect(page).to have_selector("img.my-class.some-other-class")
    end
  end
end
