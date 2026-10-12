# frozen_string_literal: true

require "rails_helper"

RSpec.describe RocketChatApiConfig, type: :config do
  subject(:config) { described_class.new }

  describe "#host" do
    it_behaves_like "a config with a Rocket.Chat host"
  end

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

  describe "#auth_cookie" do
    it "returns the cookies that authenticate the user" do
      config = described_class.new(host: "chat.example.com", user_id: "my-id", auth_token: "my-token")

      expect(config.auth_cookie).to eq("rc_uid=my-id; rc_token=my-token")
    end

    it "returns nil when API access isn't configured" do
      expect(described_class.new(host: "chat.example.com").auth_cookie).to be_nil
    end
  end

  describe "#workspace?" do
    subject(:config) { described_class.new(host: "chat.example.com", user_id: "my-id", auth_token: "my-token") }

    it "returns true for URLs on the workspace" do
      expect(config.workspace?(URI("https://Chat.example.com/avatar/john"))).to be true
    end

    it "returns false for URLs on other hosts, schemes or ports" do
      expect(config.workspace?(URI("https://files.example.com/avatar/john"))).to be false
      expect(config.workspace?(URI("http://chat.example.com/avatar/john"))).to be false
      expect(config.workspace?(URI("https://chat.example.com:8443/avatar/john"))).to be false
    end

    it "returns false when API access isn't configured" do
      config.auth_token = nil

      expect(config.workspace?(URI("https://chat.example.com/avatar/john"))).to be false
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

    it "returns false when the host was not configured" do
      unconfigured = described_class.new(user_id: "my-id", auth_token: "my-token")
      expect(unconfigured.configured?).to be false
    end
  end
end
