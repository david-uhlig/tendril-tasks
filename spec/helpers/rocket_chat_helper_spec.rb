# frozen_string_literal: true

require "rails_helper"

RSpec.describe RocketChatHelper, type: :helper do
  let(:user) { build(:user, username: "jane", uid: "b") }

  before { allow(RocketChatConfig).to receive(:host).and_return("https://chat.example.com") }

  describe "#rocketchat_link" do
    it "links to a direct message with the user on the configured host" do
      expect(helper.rocketchat_link(to: user)).to eq("https://chat.example.com/direct/jane")
    end
  end

  describe "#rocketchat_applink" do
    it "links to a direct message with the user in the app on the configured host" do
      allow(helper).to receive(:current_user).and_return(build(:user, uid: "a"))
      expect(helper.rocketchat_applink(to: user))
        .to eq("rocketchat://room?host=https://chat.example.com&rid=ab&path=direct/jane")
    end
  end
end
