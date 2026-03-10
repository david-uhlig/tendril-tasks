# frozen_string_literal: true

require "rails_helper"

RSpec.describe RocketChat::PrivateMessageDelivery, type: :notifier do
  let(:test_notification_class) do
    Class.new(ApplicationNotifier) do
      include RocketChat::PrivateMessageDelivery
      attr_accessor :recipient

      def markdown_message
        "test message"
      end

      def self.name
        "TestNotification"
      end
    end
  end

  let(:recipient) { double("Recipient") }
  let(:notification) do
    test_notification_class.new(params: { delay: 5.minutes }).tap do |n|
      n.recipient = recipient
    end
  end

  it "configures the rocket_chat_pm delivery method" do
    expect(test_notification_class.delivery_methods).to include(:rocket_chat_pm)

    delivery = test_notification_class.delivery_methods[:rocket_chat_pm]
    config = delivery.instance_variable_get(:@config)
    # In Noticed 3, the deliver_by block sets up the delivery method
    expect(config[:class]).to eq("DeliveryMethods::RocketChat::PrivateMessage")
  end

  describe "configuration options" do
    let(:delivery) { test_notification_class.delivery_methods[:rocket_chat_pm] }
    let(:config) { delivery.instance_variable_get(:@config) }

    def evaluate(notification, value)
      case value
      when Proc
        notification.instance_exec(&value)
      when Symbol
        notification.send(value)
      else
        value
      end
    end

    it "sets the url from RocketChatApiConfig" do
      allow(RocketChatApiConfig).to receive(:url).and_return("https://chat.example.com/api/v1")
      expect(evaluate(notification, config[:url])).to eq("https://chat.example.com/api/v1")
    end

    it "sets the headers from RocketChatApiConfig" do
      headers = { "X-Auth-Token" => "token", "X-User-Id" => "user" }
      allow(RocketChatApiConfig).to receive(:auth_headers).and_return(headers)
      expect(evaluate(notification, config[:headers])).to eq(headers)
    end

    it "sets the message to call markdown_message" do
      expect(evaluate(notification, config[:message])).to eq("test message")
    end

    it "sets wait from params[:delay]" do
      expect(evaluate(notification, config[:wait])).to eq(5.minutes)
    end

    it "sets raise_if_not_ok to true" do
      expect(config[:raise_if_not_ok]).to be true
    end

    describe "before_enqueue" do
      let(:before_enqueue) { config[:before_enqueue] }

      it "does not abort when RocketChatApiConfig is configured" do
        allow(RocketChatApiConfig).to receive(:configured?).and_return(true)
        # In Noticed 3, before_enqueue is executed in the context of the notification (event)
        expect { notification.instance_exec(&before_enqueue) }.not_to throw_symbol(:abort)
      end

      it "aborts when RocketChatApiConfig is not configured" do
        allow(RocketChatApiConfig).to receive(:configured?).and_return(false)
        expect { notification.instance_exec(&before_enqueue) }.to throw_symbol(:abort)
      end
    end
  end
end
