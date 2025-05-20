require "rails_helper"

class GenerateRandomIdSpec
  include Gustwave::HtmlAttributesHelper
end

RSpec.describe Gustwave::HtmlAttributesHelper, "#generate_random_id" do
  let(:helper) { GenerateRandomIdSpec.new }

  describe "#generate_random_id" do
    it "generates a random id with only a random part when no prefix or postfix is provided" do
      id = helper.generate_random_id
      expect(id).to match(/\A[a-z0-9]{8}\z/)
    end

    it "generates a random id with a prefix" do
      id = helper.generate_random_id(prefix: "dropdown")
      expect(id).to match(/\Adropdown-[a-z0-9]{8}\z/)
    end

    it "generates a random id with a postfix" do
      id = helper.generate_random_id(postfix: "menu")
      expect(id).to match(/\A[a-z0-9]{8}-menu\z/)
    end

    it "generates a random id with both prefix and postfix" do
      id = helper.generate_random_id(prefix: "dropdown", postfix: "menu")
      expect(id).to match(/\Adropdown-[a-z0-9]{8}-menu\z/)
    end

    it "generates a random id with a custom length for the random part" do
      id = helper.generate_random_id(length: 12)
      expect(id).to match(/\A[a-z0-9]{12}\z/)
    end

    it "generates a random id with a custom separator" do
      id = helper.generate_random_id(prefix: "dropdown", postfix: "menu", separator: "_")
      expect(id).to match(/\Adropdown_[a-z0-9]{8}_menu\z/)
    end

    it "returns only the random part when prefix and postfix are nil" do
      id = helper.generate_random_id(prefix: nil, postfix: nil)
      expect(id).to match(/\A[a-z0-9]{8}\z/)
    end

    it "handles an empty string as a prefix or postfix" do
      id = helper.generate_random_id(prefix: "", postfix: "")
      expect(id).to match(/\A[a-z0-9]{8}\z/)
    end
  end
end
