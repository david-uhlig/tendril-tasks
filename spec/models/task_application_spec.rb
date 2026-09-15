# frozen_string_literal: true

require "rails_helper"

RSpec.describe TaskApplication, type: :model do
  let(:user) { create(:user) }
  let(:task) { create(:task) }

  describe "validations" do
    it "is valid with a task and user" do
      expect(build(:task_application, task: task, user: user)).to be_valid
    end

    it "is invalid without a task" do
      application = build(:task_application, task: nil, user: user)

      expect(application).not_to be_valid
    end

    it "is invalid without a user" do
      application = build(:task_application, task: task, user: nil)

      expect(application).not_to be_valid
    end

    it "allows only one application per user and task" do
      create(:task_application, task: task, user: user)
      duplicate = build(:task_application, task: task, user: user)

      expect(duplicate).not_to be_valid
    end
  end

  describe "#editable?" do
    it "is editable within the grace period" do
      application = create(:task_application, task: task, user: user)

      expect(application).to be_editable
    end

    it "is not editable after the grace period" do
      application = create(:task_application, task: task, user: user)
      application.update_column(:created_at, TaskApplication::GRACE_PERIOD.ago - 1.second)

      expect(application.reload).not_to be_editable
    end

    it "keeps the result consistent for the model instance" do
      application = create(:task_application, task: task, user: user)

      expect(application).to be_editable

      application.update_column(:created_at, TaskApplication::GRACE_PERIOD.ago - 1.second)

      expect(application).to be_editable
    end
  end

  describe "#update_if_editable" do
    it "updates the application within the grace period" do
      application = create(:task_application, task: task, user: user)

      result = application.update_if_editable(comment: "Updated comment")

      expect(result).to be(true)
      expect(application.reload.comment).to eq("Updated comment")
    end

    it "does not update the application after the grace period" do
      application = create(:task_application, task: task, user: user)
      application.update_column(:created_at, TaskApplication::GRACE_PERIOD.ago - 1.second)

      result = application.update_if_editable(comment: "Updated comment")

      expect(result).to be(false)
      expect(application.reload.comment).not_to eq("Updated comment")
    end

    it "returns false when the update fails validation" do
      application = create(:task_application, task: task, user: user)
      allow(application).to receive(:update).and_return(false)

      expect(application.update_if_editable(comment: "Updated comment")).to be(false)
    end
  end

  describe "#destroy_or_withdraw!" do
    it "destroys the application within the grace period" do
      application = create(:task_application, task: task, user: user)

      expect {
        application.destroy_or_withdraw!
      }.to change(described_class, :count).by(-1)

      expect(application).to be_destroyed
    end

    it "withdraws the application after the grace period" do
      application = create(:task_application, task: task, user: user)
      application.update_column(:created_at, TaskApplication::GRACE_PERIOD.ago - 1.second)

      expect {
        application.destroy_or_withdraw!
      }.not_to change(described_class, :count)

      expect(application.reload).to be_withdrawn
      expect(application.withdrawn_at).to be_present
    end

    it "does not change an already withdrawn application" do
      application = create(
        :task_application,
        task: task,
        user: user,
        status: :withdrawn,
        withdrawn_at: 1.hour.ago
      )
      application.update_column(:created_at, TaskApplication::GRACE_PERIOD.ago - 1.second)
      original_withdrawn_at = application.withdrawn_at

      expect {
        application.destroy_or_withdraw!
      }.not_to change(described_class, :count)

      expect(application.reload.withdrawn_at).to eq(original_withdrawn_at)
    end
  end

  describe "notifications" do
    let(:received_notification) { instance_double("TaskApplicationReceivedNotification", deliver: true) }
    let(:withdrawn_notification) { instance_double("TaskApplicationWithdrawnNotification", deliver: true) }

    before do
      allow(TaskApplicationReceivedNotification)
        .to receive(:with)
              .and_return(received_notification)

      allow(TaskApplicationWithdrawnNotification)
        .to receive(:with)
              .and_return(withdrawn_notification)
    end

    it "notifies coordinators after creation" do
      create(:task_application, task: task, user: user)

      expect(TaskApplicationReceivedNotification).to have_received(:with).with(
        record: an_instance_of(TaskApplication),
        delay: TaskApplication::NOTIFICATION_DELAY
      )
      expect(received_notification).to have_received(:deliver)
    end

    it "notifies coordinators when an application is withdrawn" do
      application = create(:task_application, task: task, user: user)
      application.update_column(:created_at, TaskApplication::GRACE_PERIOD.ago - 1.second)

      application.destroy_or_withdraw!

      expect(TaskApplicationWithdrawnNotification).to have_received(:with).with(
        record: application
      )
      expect(withdrawn_notification).to have_received(:deliver)
    end

    it "does not notify again when an already withdrawn application is updated" do
      application = create(
        :task_application,
        task: task,
        user: user,
        status: :withdrawn,
        withdrawn_at: 1.hour.ago
      )

      application.update!(comment: "Updated comment")

      expect(TaskApplicationWithdrawnNotification).not_to have_received(:with)
    end
  end
end
