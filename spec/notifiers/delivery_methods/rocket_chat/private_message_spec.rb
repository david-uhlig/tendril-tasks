# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeliveryMethods::RocketChat::PrivateMessage, type: :notifier do
  let(:recipient) { double("Recipient", username: "test_user") }
  let(:notification) { double("Notification", recipient:) }
  let(:options) do
    {
      url: "https://rocket.chat/api/v1",
      headers: { "X-Auth-Token" => "token", "X-User-Id" => "user_id" },
      message: "Hello world",
      raise_if_not_ok: true
    }
  end
  let(:delivery_method) { described_class.new }
  let(:response) { double("Response", code: "200") }

  before do
    allow(delivery_method).to receive(:notification).and_return(notification)
    allow(delivery_method).to receive(:recipient).and_return(recipient)
    # Mocking evaluate_option as it's used in the class
    allow(delivery_method).to receive(:evaluate_option) { |key| options[key] }
    allow(delivery_method).to receive(:post_request).and_return(response)
  end

  describe "#deliver" do
    it "sends a POST request to the correct endpoint with correct payload" do
      expected_url = "https://rocket.chat/api/v1/chat.postMessage"
      expected_payload = { channel: "@test_user", text: "Hello world" }
      expected_headers = options[:headers]

      delivery_method.deliver

      expect(delivery_method).to have_received(:post_request).with(
        expected_url,
        headers: expected_headers,
        json: expected_payload
      )
    end

    it "returns the response on success" do
      expect(delivery_method.deliver).to eq(response)
    end

    context "when response is not OK" do
      let(:response) { double("Response", code: "400", body: "Bad Request") }

      context "and raise_if_not_ok is true" do
        it "raises Noticed::ResponseUnsuccessful" do
          expect {
            delivery_method.deliver
          }.to raise_error(Noticed::ResponseUnsuccessful)
        end
      end

      context "and raise_if_not_ok is false" do
        before do
          options[:raise_if_not_ok] = false
        end

        it "does not raise an error and returns the response" do
          expect(delivery_method.deliver).to eq(response)
        end
      end
    end
  end

  describe "#raise_if_not_ok?" do
    it "returns true by default when option is missing or nil" do
      options.delete(:raise_if_not_ok)
      expect(delivery_method.raise_if_not_ok?).to be true
    end

    it "returns the evaluated option when present" do
      options[:raise_if_not_ok] = false
      expect(delivery_method.raise_if_not_ok?).to be false
    end
  end

  describe "#response_http_ok?" do
    it "returns true when code is 200" do
      delivery_method.instance_variable_set(:@response, double("Response", code: "200"))
      expect(delivery_method.response_http_ok?).to be true
    end

    it "returns false when code is not 200" do
      delivery_method.instance_variable_set(:@response, double("Response", code: "400"))
      expect(delivery_method.response_http_ok?).to be false
    end
  end
end
