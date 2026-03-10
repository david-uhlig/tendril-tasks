# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MarkdownHelper do
  describe ".link_to" do
    it "creates an anchor element" do
      expect(described_class.link_to("Example", "https://example.com")).to eq("[Example](https://example.com)")
    end
  end

  describe ".quote" do
    it "block quotes single line text" do
      expect(described_class.quote("This is a quote")).to eq("> This is a quote")
    end

    it "block quotes multiple lines of text" do
      text = "This is a quote\nover multiple lines."
      expect(described_class.quote(text)).to eq("> This is a quote\n> over multiple lines.")
    end

    it "returns an empty string if text is blank" do
      expect(described_class.quote("")).to eq("")
      expect(described_class.quote(nil)).to eq("")
    end

    it "preserves blank lines in multi-line text" do
      text = "Line 1\n\nLine 3"
      expect(described_class.quote(text)).to eq("> Line 1\n>\n> Line 3")
    end

    it "strips blank lines leading and trailing blank lines" do
      text = "\nLine 1\nLine 2\n"
      expect(described_class.quote(text)).to eq("> Line 1\n> Line 2")
    end
  end

  describe ".italic" do
    it "italicizes text with underscores by default" do
      expect(described_class.italic("example")).to eq("_example_")
    end

    it "italicizes text with stars if specified" do
      expect(described_class.italic("example", symbol: "*")).to eq("*example*")
    end

    it "italicizes each line of text" do
      text = "Line 1\nLine 2"
      expect(described_class.italic(text)).to eq("_Line 1_\n_Line 2_")
    end

    it "returns an empty string if text is blank" do
      expect(described_class.italic("")).to eq("")
      expect(described_class.italic(nil)).to eq("")
    end

    it "preserves blank lines in multi-line text" do
      text = "Line 1\n\nLine 3"
      expect(described_class.italic(text)).to eq("_Line 1_\n\n_Line 3_")
    end
  end

  describe ".italicize" do
    it "is an alias for italic" do
      expect(described_class.italicize("example")).to eq("_example_")
    end
  end

  describe ".bold" do
    it "bolds text with stars by default" do
      expect(described_class.bold("example")).to eq("**example**")
    end

    it "bolds text with underscores if specified" do
      expect(described_class.bold("example", symbol: "_")).to eq("__example__")
    end

    it "bolds each line of text" do
      text = "Line 1\nLine 2"
      expect(described_class.bold(text)).to eq("**Line 1**\n**Line 2**")
    end

    it "returns an empty string if text is blank" do
      expect(described_class.bold("")).to eq("")
      expect(described_class.bold(nil)).to eq("")
    end

    it "preserves blank lines in multi-line text" do
      text = "Line 1\n\nLine 3"
      expect(described_class.bold(text)).to eq("**Line 1**\n\n**Line 3**")
    end
  end
end
