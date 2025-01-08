require "rails_helper"

RSpec.describe Gustwave::Component, type: :component do
  let(:component) { described_class.new }

  describe "#normalize_keys" do
    it "normalizes simple keys" do
      options = { "key_one" => "value1", "key_two" => "value2" }
      expected = { "key-one": "value1", "key-two": "value2" }
      expect(component.send(:normalize_keys, options)).to eq(expected)
    end

    it "normalizes aria and data keys" do
      options = { "aria" => { "label" => "Close" }, "data" => { "toggle" => "modal" } }
      expected = { "aria-label": "Close", "data-toggle": "modal" }
      expect(component.send(:normalize_keys, options)).to eq(expected)
    end

    it "normalizes mixed keys" do
      options = { "key_one" => "value1", "aria" => { "label" => "Close" }, "data" => { "toggle" => "modal" } }
      expected = { "key-one": "value1", "aria-label": "Close", "data-toggle": "modal" }
      expect(component.send(:normalize_keys, options)).to eq(expected)
    end

    it "handles empty hash" do
      options = {}
      expected = {}
      expect(component.send(:normalize_keys, options)).to eq(expected)
    end

    it "handles nil value" do
      options = { "key_one" => nil }
      expected = { "key-one": nil }
      expect(component.send(:normalize_keys, options)).to eq(expected)
    end
  end
end
