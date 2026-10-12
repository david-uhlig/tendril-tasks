# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Rocket.Chat OmniAuth initializer" do
  around do |example|
    original = Devise.omniauth_configs[:rocketchat]
    example.run
  ensure
    Devise.omniauth_configs[:rocketchat] = original
  end

  def client
    config = Devise.omniauth_configs[:rocketchat]
    config.strategy_class.new(nil, *config.args).client
  end

  it "uses the configured authorize and token URLs" do
    allow(RocketChatConfig).to receive_messages(authorize_url: "/custom/authorize",
                                                token_url: "https://auth.example.com/custom/token")
    load Rails.root.join("config/initializers/rocketchat.rb")

    expect(client.authorize_url).to eq("#{RocketChatConfig.host}/custom/authorize")
    expect(client.token_url).to eq("https://auth.example.com/custom/token")
  end
end
