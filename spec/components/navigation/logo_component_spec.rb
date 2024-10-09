# frozen_string_literal: true

require "rails_helper"

RSpec.describe Navigation::LogoComponent, type: :component do
  context "with default options" do
    before(:each) do
      render_inline(described_class.new)
    end

    it "renders the fallback label" do
      expect(page).to have_text(described_class::FALLBACK_LABEL)
    end

    it "doesn't render a logo" do
      expect(page).not_to have_selector("img")
    end

    it "links to #" do
      expect(page).to have_selector("a[href='#']")
    end
  end

  context "with content" do
    it "renders content" do
      render_inline(described_class.new) { "content" }
      expect(page).to have_text("content")
    end

    it "renders empty string" do
      render_inline(described_class.new) { "" }
      span = page.find("span")
      expect(span.text.strip).to eq("")
    end

    it "prioritizes content over label" do
      render_inline(described_class.new(label: "label_text")) { "content" }
      expect(page).to have_text("content")
      expect(page).not_to have_text("label_text")
    end
  end

  context "with label" do
    it "renders label text" do
      render_inline(described_class.new(label: "label_text"))
      expect(page).to have_text("label_text")
    end

    it "renders empty label text" do
      render_inline(described_class.new(label: ""))
      span = page.find("span")
      expect(span.text.strip).to eq("")
    end
  end

  context "with logo" do
    before(:all) do
      @test_image_path = Rails.root.join("spec", "assets", "images", "for-tests.jpg").to_s
    end

    it "renders image" do
      render_inline(described_class.new(src: @test_image_path)) { "content" }
      expect(page).to have_selector("img[src='#{@test_image_path}']")
    end

    it "renders alt text" do
      render_inline(described_class.new(src: @test_image_path, alt: "alt text")) { "content" }
      expect(page).to have_selector("img[alt='alt text']")
    end
  end

  context "with url" do
    it "renders link" do
      render_inline(described_class.new(href: "https://example.com")) { "content" }
      expect(page).to have_selector("a[href='https://example.com']")
    end
  end
end
