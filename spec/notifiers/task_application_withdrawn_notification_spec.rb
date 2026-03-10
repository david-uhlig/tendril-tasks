# frozen_string_literal: true

require "rails_helper"

RSpec.describe TaskApplicationWithdrawnNotification, type: :notifier do
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

      expect(notification.send(:evaluate_recipients)).to match_array(coordinators)
    end
  end

  describe "delivery methods" do
    it "includes rocket_chat_pm" do
      expect(described_class.delivery_methods).to include(:rocket_chat_pm)
    end
  end

  describe "#markdown_message" do
    let(:applicant) { task_application.user }
    let(:task) { task_application.task }
    let(:project) { task.project }
    let(:noti) { described_class::Notification.new(event: notification) }

    it "builds the correct markdown message" do
      I18n.with_locale(:en) do
        allow(noti).to receive(:url_for).with(task).and_return("http://example.com/tasks/#{task.id}")
        allow(noti).to receive(:url_for).with(project).and_return("http://example.com/projects/#{project.id}")

        message = noti.markdown_message

        expect(message).to include("@#{applicant.username} has withdrawn from [#{task.title}](http://example.com/tasks/#{task.id}) ❌")
        expect(message).to include("* Project: [#{project.title}](http://example.com/projects/#{project.id})")
        expect(message).to include("* Applications: #{task.task_applications.count}")
      end
    end
  end
end
