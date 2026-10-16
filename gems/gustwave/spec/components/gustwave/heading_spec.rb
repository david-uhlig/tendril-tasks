# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::Heading, type: :component do
  it "renders the given tag" do
    render_inline(described_class.new("Title", tag: :h3))

    expect(page).to have_selector("h3#title", text: "Title")
  end

  it "defaults to h2 when no tag is given" do
    render_inline(described_class.new("Title", tag: nil))

    expect(page).to have_selector("h2", text: "Title")
  end

  describe "id" do
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

    it "doesn't need the view context" do
      component = described_class.new("Getting Started", tag: :h2)
      allow(component).to receive(:helpers).and_raise("helpers must not be used")

      render_inline(component)

      expect(page).to have_selector("h2#getting-started")
    end
  end

  it "raises for an unknown tag" do
    expect { described_class.new("Title", tag: :h7) }
      .to raise_error(Gustwave::Options::UnknownValueError, /Unknown value :h7 for :tag/)
  end

  it "falls back to h2 for an unknown tag in production" do
    allow(Rails.env).to receive(:production?).and_return(true)
    render_inline(described_class.new("Title", tag: :h7))

    expect(page).to have_selector("h2", text: "Title")
  end
end
