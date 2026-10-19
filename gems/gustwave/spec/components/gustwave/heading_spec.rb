# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::Heading, type: :component do
  it "renders the given tag" do
    render_inline(described_class.new("Title", tag: :h3))

    expect(page).to have_selector("h3#title", text: "Title")
  end

  it "defaults to h2 when no tag is given" do
    render_inline(described_class.new("Title"))

    expect(page).to have_selector("h2", text: "Title")
  end

  it "defaults to h2 for a nil tag" do
    render_inline(described_class.new("Title", tag: nil))

    expect(page).to have_selector("h2", text: "Title")
  end

  describe "size" do
    it "derives the size from the tag" do
      render_inline(described_class.new("Title", tag: :h4))

      expect(page).to have_selector("h4.text-3xl")
    end

    it "derives the size from the fallback tag" do
      render_inline(described_class.new("Title", tag: nil))

      expect(page).to have_selector("h2.text-5xl")
    end

    it "keeps an explicit size" do
      render_inline(described_class.new("Title", tag: :h1, size: :xs))

      expect(page).to have_selector("h1.text-xl")
    end
  end

  describe "id" do
    it "falls back when the text produces an empty id" do
      render_inline(described_class.new("???", tag: :h2))

      expect(page).to have_selector("h2[id^='heading-']")
    end

    it "makes the fallback id unique" do
      ids = 2.times.map do
        render_inline(described_class.new("???", tag: :h2)).css("h2").first["id"]
      end

      expect(ids.uniq.size).to eq(2)
    end

    it "derives the id from the text" do
      render_inline(described_class.new("Getting Started", tag: :h2))

      expect(page).to have_selector("h2#getting-started")
    end

    it "derives the id from the content block" do
      render_inline(described_class.new(tag: :h2)) { "From a Block" }

      expect(page).to have_selector("h2#from-a-block")
    end

    it "strips tags from the id" do
      render_inline(described_class.new(tag: :h2)) { "Hello <em>World</em>".html_safe }

      expect(page).to have_selector("h2#hello-world")
    end

    it "keeps an explicit id" do
      render_inline(described_class.new("Title", tag: :h2, id: "custom"))

      expect(page).to have_selector("h2#custom")
    end
  end

  describe "responsive" do
    it "renders the responsive sizes" do
      render_inline(described_class.new("Title", tag: :h2, responsive: true))

      expect(page).to have_selector("h2[class~='md:text-4xl']")
    end

    it "renders no responsive sizes by default" do
      render_inline(described_class.new("Title", tag: :h2))

      expect(page).not_to have_selector("h2[class~='md:text-4xl']")
    end
  end

  it_behaves_like "a text and block content renderer", selector: "h2"

  it "falls back to h2 for an unknown tag when Gustwave isn't strict" do
    Gustwave.strict = false
    render_inline(described_class.new("Title", tag: :h7))

    expect(page).to have_selector("h2", text: "Title")
  end
end
