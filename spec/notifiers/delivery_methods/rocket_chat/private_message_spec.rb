# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeliveryMethods::RocketChat::PrivateMessage, type: :notifier do
  subject(:deliver) { delivery_method.deliver }

  let(:recipient) { double("Recipient", username: "test_user") }
  let(:delivery_method) { described_class.new }
  let(:response) { double("Response", code: response_code, body: response_body) }
  let(:response_code) { "200" }
  let(:response_body) { "OK" }
  let(:headers) do
    {
      "X-Auth-Token" => "token",
      "X-User-Id" => "user_id"
    }
  end
  let(:config) do
    {
      url: "https://chat.example.com/api/v1",
      headers:,
      message: "Hello world",
      raise_if_not_ok:
    }
  end
  let(:raise_if_not_ok) { true }

  before do
    allow(delivery_method).to receive_messages(
                                config:,
                                recipient:,
                                post_request: response
                              )
  end

  describe "#deliver" do
    context "when Rocket.Chat accepts the message" do
      it "sends a private message to the recipient" do
        deliver

        expect(delivery_method).to have_received(:post_request).with(
          "https://chat.example.com/api/v1/chat.postMessage",
          headers:,
          json: {
            channel: "@test_user",
            text: "Hello world"
          }
        )
      end

      it "returns Rocket.Chat's response" do
        expect(deliver).to eq(response)
      end
    end

    context "when Rocket.Chat rejects the message" do
      let(:response_code) { "400" }
      let(:response_body) { "Bad Request" }

      context "when raise_if_not_ok is omitted" do
        let(:raise_if_not_ok) { nil }

        it "raises Noticed::ResponseUnsuccessful by default" do
          expect { deliver }.to raise_error(Noticed::ResponseUnsuccessful)
        end
      end

      context "when raise_if_not_ok is enabled" do
        let(:raise_if_not_ok) { true }

        it "raises Noticed::ResponseUnsuccessful" do
          expect { deliver }.to raise_error(Noticed::ResponseUnsuccessful)
        end

        it "does not expose authentication header values in the error" do
          expect { deliver }.to raise_error(Noticed::ResponseUnsuccessful) { |error|
            aggregate_failures do
              expect(error.message).not_to include("token")
              expect(error.message).not_to include("user_id")
              expect(headers).to eq(
                                   "X-Auth-Token" => "token",
                                   "X-User-Id" => "user_id"
                                 )
            end
          }
        end
      end

      context "when raise_if_not_ok is disabled" do
        let(:raise_if_not_ok) { false }

        it "returns Rocket.Chat's response without raising an error" do
          expect(deliver).to eq(response)
        end
      end
    end
  end
end
