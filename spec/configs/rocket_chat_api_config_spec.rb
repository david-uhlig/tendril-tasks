# frozen_string_literal: true

require "rails_helper"

RSpec.describe RocketChatApiConfig, type: :config do
  subject(:config) { described_class.new }

  describe "#url" do
    it "returns a well-formed URL with https by default" do
      config.host = "example.com"
      config.path = "/api/v1"
      expect(config.url).to eq("https://example.com/api/v1")
    end

    it "preserves existing http scheme" do
      config.host = "http://example.com"
      config.path = "/api/v1"
      expect(config.url).to eq("http://example.com/api/v1")
    end

    it "preserves existing https scheme" do
      config.host = "https://example.com"
      config.path = "/api/v1"
      expect(config.url).to eq("https://example.com/api/v1")
    end

    it "concatenates the host and path correctly" do
      config.host = "chat.company.com"
      config.path = "/custom/api"
      expect(config.url).to eq("https://chat.company.com/custom/api")
    end
  end

  describe "#auth_headers" do
    it "returns the correct authentication headers" do
      config.auth_token = "my-token"
      config.user_id = "my-id"
      expect(config.auth_headers).to eq(
        "X-Auth-Token": "my-token",
        "X-User-Id": "my-id"
      )
    end
  end

  describe "#configured?" do
    before do
      config.host = "example.com"
      config.user_id = "my-id"
      config.auth_token = "my-token"
    end

    it "returns true when all required settings are present" do
      expect(config.configured?).to be true
    end

    it "returns false when host is missing" do
      config.host = nil
      expect(config.configured?).to be false
    end

    it "returns false when user_id is missing" do
      config.user_id = ""
      expect(config.configured?).to be false
    end

    it "returns false when auth_token is missing" do
      config.auth_token = nil
      expect(config.configured?).to be false
    end
  end
end
