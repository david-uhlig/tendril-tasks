# frozen_string_literal: true

require "rails_helper"

RSpec.describe RocketChatConfig, type: :config do
  subject(:config) do
    described_class.new(host: "https://chat.example.com",
                        client_id: "client-id",
                        client_secret: "client-secret")
  end

  describe "#host" do
    it_behaves_like "a config with a Rocket.Chat host"
  end

  describe "#origin" do
    it "returns the scheme and host of the workspace" do
      expect(config.origin).to eq("https://chat.example.com")
    end

    it "drops the path and keeps a non-default port" do
      config.host = "http://localhost:5000/chat/"
      expect(config.origin).to eq("http://localhost:5000")
    end

    it "returns nil when the host is blank" do
      config.host = ""
      expect(config.origin).to be_nil
    end
  end

  describe "#configured?" do
    it "returns true when host, client ID and client secret are present" do
      expect(config).to be_configured
    end

    %i[host client_id client_secret].each do |attribute|
      it "returns false when #{attribute} is blank" do
        config.public_send(:"#{attribute}=", "")
        expect(config).not_to be_configured
      end
    end
  end
end
