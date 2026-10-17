require "rails_helper"

RSpec.describe Gustwave::Component, type: :component do
  describe "#configure_html_attributes" do
    let(:component) { described_class.new }

    context "with default values" do
      it "returns an empty hash" do
        result = component.configure_html_attributes
        expect(result).to eq({})
      end
    end

    context "with only default_attrs" do
      it "returns the default_attrs" do
        default_attrs = { id: "default_id", class: "default_class" }
        result = component.configure_html_attributes(**default_attrs)
        expect(result).to eq({ id: "default_id", class: "default_class" })
      end
    end

    context "with only overwrite_attrs" do
      it "returns the overwrite_attrs" do
        overwrite_attrs = { id: "overwrite_id", class: "overwrite_class" }
        result = component.configure_html_attributes(overwrite_attrs)
        expect(result).to eq({ id: "overwrite_id", class: "overwrite_class" })
      end
    end

    context "with default_attrs and overwrite_attrs apart from the class attribute" do
      it "behaves like Ruby merge" do
        default_attrs = { id: "default_id", lang: "en", draggable: true }
        overwrite_attrs = { id: "overwrite_id", title: "overwrite_title", draggable: false }
        result = component.configure_html_attributes(
          overwrite_attrs,
          **default_attrs
        )
        expect(result).to eq({ id: "overwrite_id", lang: "en", title: "overwrite_title", draggable: false })
      end
    end

    context "with data and aria hashes in both" do
      it "merges the data hashes" do
        result = component.configure_html_attributes(
          { data: { controller: "x" } },
          data: { "dropdown-toggle": "menu" }
        )
        expect(result).to eq({ data: { "dropdown-toggle": "menu", controller: "x" } })
      end

      it "merges the aria hashes" do
        result = component.configure_html_attributes(
          { aria: { label: "Overdue" } },
          aria: { hidden: true }
        )
        expect(result).to eq({ aria: { hidden: true, label: "Overdue" } })
      end

      it "lets overwrite_attrs keys within the hashes take precedence" do
        result = component.configure_html_attributes(
          { aria: { hidden: false } },
          aria: { hidden: true, live: "polite" }
        )
        expect(result).to eq({ aria: { hidden: false, live: "polite" } })
      end

      it "merges string keys with symbol keys" do
        result = component.configure_html_attributes(
          { "data" => { "controller" => "x", "hidden" => "no" } },
          data: { "hidden" => "yes" }
        )
        expect(result).to eq({ data: { hidden: "no", controller: "x" } })
      end

      it "replaces a hash with a value that isn't a hash" do
        result = component.configure_html_attributes(
          { data: nil },
          data: { "dropdown-toggle": "menu" }
        )
        expect(result).to eq({ data: nil })
      end
    end

    context "when overwrite_class_attr is false" do
      it "merges the class attribute semantically" do
        default_attrs = { class: "bg-white text-gray-800" }
        overwrite_attrs = { class: "bg-red-500 some-custom-class" }
        result = component.configure_html_attributes(
          overwrite_attrs,
          overwrite_class_attr: false,
          **default_attrs
        )
        expect(result).to eq({ class: "text-gray-800 bg-red-500 some-custom-class" })
      end

      it "overwrite_attrs class can be empty" do
        default_attrs = { class: "bg-white text-gray-800" }
        overwrite_attrs = { class: "" }
        result = component.configure_html_attributes(
          overwrite_attrs,
          overwrite_class_attr: false,
          **default_attrs
        )
        expect(result).to eq({ class: "bg-white text-gray-800" })
      end

      it "keeps the default_attrs class when overwrite_attrs class is nil" do
        default_attrs = { class: "bg-white text-gray-800" }
        overwrite_attrs = { id: "overwrite_id", class: nil }
        result = component.configure_html_attributes(
          overwrite_attrs,
          overwrite_class_attr: false,
          **default_attrs
        )
        expect(result).to eq({ id: "overwrite_id", class: "bg-white text-gray-800" })
      end

      it "default_attrs class can be empty" do
        default_attrs = { class: "" }
        overwrite_attrs = { class: "bg-red-500 some-custom-class" }
        result = component.configure_html_attributes(
          overwrite_attrs,
          overwrite_class_attr: false,
          **default_attrs
        )
        expect(result).to eq({ class: "bg-red-500 some-custom-class" })
      end
    end

    context "when overwrite_class_attr is true" do
      it "overwrites the default_attrs class attribute" do
        default_attrs = { class: "bg-white text-gray-800" }
        overwrite_attrs = { class: "bg-red-500 some-custom-class" }
        result = component.configure_html_attributes(
          overwrite_attrs,
          overwrite_class_attr: true,
          **default_attrs
        )
        expect(result).to eq({ class: "bg-red-500 some-custom-class" })
      end
    end
  end
end
