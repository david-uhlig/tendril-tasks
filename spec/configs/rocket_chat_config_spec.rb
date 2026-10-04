# frozen_string_literal: true

require "rails_helper"

RSpec.describe RocketChatConfig, type: :config do
  subject(:config) do
    described_class.new(host: "https://chat.example.com",
                        client_id: "client-id",
                        client_secret: "client-secret")
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
