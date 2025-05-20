require "rails_helper"

class NormalizeHtmlAttributesSpec
  include Gustwave::HtmlAttributesHelper
end

RSpec.describe Gustwave::HtmlAttributesHelper, type: :helper do
  let(:helper) { NormalizeHtmlAttributesSpec.new }

  context "without attributes" do
    it "handles nil value" do
      options = nil
      expected = {}
      expect(helper.normalize_html_attributes(**options)).to eq(expected)
    end

    it "handles empty hash" do
      options = {}
      expected = {}
      expect(helper.normalize_html_attributes(**options)).to eq(expected)
    end
  end

  context "with regular attributes" do
    it "symbolizes keys" do
      options = { "id" => "id_value", name: "name_value" }
      expected = { id: "id_value", name: "name_value" }
      expect(helper.normalize_html_attributes(**options)).to eq(expected)
    end

    it "does not hyphenize keys" do
      options = { "aria_label" => "aria_label_value", accept_charset: "accept_charset_value" }
      expected = { "aria_label": "aria_label_value", "accept_charset": "accept_charset_value" }
      expect(helper.normalize_html_attributes(**options)).to eq(expected)
    end
  end

  context "with data attributes" do
    it "hyphenizes the data hash" do
      options = { data: { toggle: "modal", controller: "hello" } }
      expected = { "data-toggle": "modal", "data-controller": "hello" }
      expect(helper.normalize_html_attributes(**options)).to eq(expected)
    end

    it "hyphenizes nested attributes" do
      options = { data: { hello_target: "name", action: "click->hello#greet" } }
      expected = { "data-hello-target": "name", "data-action": "click->hello#greet" }
      expect(helper.normalize_html_attributes(**options)).to eq(expected)
    end
  end

  context "with aria attributes" do
    it "hyphenizes the aria hash" do
      options = { aria: { label: "Close" } }
      expected = { "aria-label": "Close" }
      expect(helper.normalize_html_attributes(**options)).to eq(expected)
    end
  end

  it "does not alter the original hash" do
    options = { aria: { label: "Close" }, data: { toggle: "modal" }, id: "id_value", name: "name_value" }
    helper.normalize_html_attributes(**options)
    expect(options).to eq(aria: { label: "Close" }, data: { toggle: "modal" }, id: "id_value", name: "name_value")
  end
end
