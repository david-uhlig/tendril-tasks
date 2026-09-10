require 'rails_helper'

RSpec.describe Footer::Link, type: :model do
  describe "normalizations" do
    it "removes leading and trailing whitespace from the title" do
      link = Footer::Link.new(title: "   Example Title  ")
      expect(link.title).to eq("Example Title")
    end

    it "removes leading and trailing whitespace from the href" do
      link = Footer::Link.new(href: "   https://example.com/   ")
      expect(link.href).to eq("https://example.com/")
    end
  end

  describe "a link" do
    let!(:link) { Footer::Link.new(title: "Example Title", href: "https://example.com/") }

    it "is not valid without a href" do
      link = Footer::Link.new(href: nil)
      expect(link).not_to be_valid
    end

    it "is not valid with an empty href" do
      link = Footer::Link.new(href: "    ")
      expect(link).not_to be_valid
    end

    it "is not valid without a title" do
      link = Footer::Link.new(title: nil)
      expect(link).not_to be_valid
    end

    it "is not valid with an empty title" do
      link = Footer::Link.new(title: "    ")
      expect(link).not_to be_valid

      link = Footer::Link.new(title: "\n")
      expect(link).not_to be_valid

      link = Footer::Link.new(title: "\t")
      expect(link).not_to be_valid
    end
  end

  describe "a safe link" do
    let!(:link) { Footer::Link.new(title: "Example Title", href: "https://example.com/") }

    it "is valid with a relative path" do
      link.href = "/relative/path"
      expect(link).to be_valid
    end

    it "is valid with a http link" do
      link.href = "http://example.com"
      expect(link).to be_valid
    end

    it "is valid with an https link" do
      link.href = "https://example.com"
      expect(link).to be_valid
    end

    it "is valid without a scheme with just the host" do
      link.href = "example.com"
      expect(link).to be_valid
    end
  end

  describe "an unsafe link" do
    let!(:link) { Footer::Link.new(title: "Example Title", href: "javascript:alert(0);") }

    it "is not valid starting with the admin path" do
      link.href = "/admin"
      expect(link).to_not be_valid
    end

    it "is not valid with a javascript uri" do
      link.href = "javascript:void(0)"
      expect(link).to_not be_valid
    end

    it "is not valid with a data uri" do
      link.href = "data:text/html,Hello%20World"
      expect(link).to_not be_valid
    end

    it "is not valid with userinfo" do
      link.href = "https://example.com@malicious.com"
      expect(link).to_not be_valid
    end
  end

  context "#attributes" do
    it "returns a hash of attributes" do
      link = Footer::Link.new(title: "Example Title", href: "https://example.com/")
      expect(link.attributes).to eq({ "title" => "Example Title", "href" => "https://example.com/" })
    end
  end

  context "#href" do
    it "returns unsafe href unfiltered" do
      link = Footer::Link.new(title: "Example Title", href: "javascript:alert(0);")
      expect(link.href).to eq("javascript:alert(0);")
    end
  end

  context "#safe_href" do
    let!(:link) { Footer::Link.new(title: "Example Title", href: "http://example.com") }

    context "when the href starts with the http scheme" do
      it "returns the href" do
        link.href = "http://example.com"
        expect(link.safe_href).to eq(link.href)
      end
    end

    context "when the href starts with the https scheme" do
      it "returns the href" do
        link.href = "https://example.com"
        expect(link.safe_href).to eq(link.href)
      end
    end

    context "when the href starts with a relative path" do
      it "returns the href" do
        link.href = "/relative/path"
        expect(link.safe_href).to eq(link.href)
      end
    end

    context "when the href starts without a scheme" do
      it "returns the href" do
        link.href = "example.com"
        expect(link.safe_href).to eq(link.href)
      end
    end

    context "when the href starts with javascript uri" do
      it "returns the root path" do
        link.href = "javascript:alert(0);"
        expect(link.safe_href).to eq("/")
      end
    end

    context "when the href starts with a data uri" do
      it "returns the root path" do
        link.href = "data:text/html,Hello%20World"
        expect(link.safe_href).to eq("/")
      end
    end

    context "when the href contains userinfo" do
      it "returns the root path" do
        link.href = "https://example.com@malicious.com"
        expect(link.safe_href).to eq("/")
      end
    end
  end
end
