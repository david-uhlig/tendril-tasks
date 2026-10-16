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
