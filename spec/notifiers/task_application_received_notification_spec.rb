# frozen_string_literal: true

require "rails_helper"

RSpec.describe TaskApplicationReceivedNotification, type: :notifier do
  let(:task_application) { create(:task_application) }
  let(:notification) { described_class.with(record: task_application) }

  describe "validations" do
    it "is valid with a record" do
      expect(notification).to be_valid
    end

    it "is invalid without a record" do
      notification = described_class.with(record: nil)
      expect(notification).to be_invalid
    end
  end

  describe "recipients" do
    it "returns the task coordinators" do
      coordinators = create_list(:user, 2)
      task_application.task.coordinators = coordinators

      # In Noticed 3, recipients are defined on the event class and can be evaluated
      # using the evaluate_recipients method.
      expect(notification.send(:evaluate_recipients)).to match_array(coordinators)
    end
  end

  describe "delivery methods" do
    it "includes rocket_chat_pm" do
      # Note: Noticed::Event.delivery_methods returns a hash of DeliverBy objects
      expect(described_class.delivery_methods).to include(:rocket_chat_pm)
    end
  end

  describe "#markdown_message" do
    let(:applicant) { task_application.user }
    let(:task) { task_application.task }
    let(:project) { task.project }
    let(:noti) { described_class::Notification.new(event: notification) }

    it "builds the correct markdown message" do
      # Set locale to :en to match expected strings in the test
      I18n.with_locale(:en) do
        # In Noticed 3, methods inside notification_methods are defined on the Notification class
        # The Notification class has access to the event via the event association

        # Mock url_for to avoid routing issues in notifier specs
        # Since Noticed 3 delegates missing methods from Notification to event,
        # we need to ensure they are available where expected.
        allow(noti).to receive(:url_for).with(task).and_return("http://example.com/tasks/#{task.id}")
        allow(noti).to receive(:url_for).with(project).and_return("http://example.com/projects/#{project.id}")

        message = noti.markdown_message

        expect(message).to include("@#{applicant.username} has signed up for [#{task.title}](http://example.com/tasks/#{task.id}) 👋🏻")
        expect(message).to include("* Project: [#{project.title}](http://example.com/projects/#{project.id})")
        expect(message).to include("* Applications: #{task.task_applications.count}")
        expect(message).to include("_#{task_application.comment}_")
      end
    end

    it "handles missing comments gracefully" do
      I18n.with_locale(:en) do
        task_application.comment = nil
        allow(noti).to receive(:url_for).and_return("http://example.com")

        message = noti.markdown_message
        expect(message).not_to end_with("\n\n")
      end
    end
  end
end
