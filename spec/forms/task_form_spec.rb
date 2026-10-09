require "rails_helper"

RSpec.describe TaskForm do
  describe "#changed?" do
    let(:task) { create(:task, coordinators: create_list(:user, 2)) }
    let(:form) { described_class.new(task) }

    it "is false when the submitted coordinators match the current ones" do
      form.coordinator_ids = task.coordinator_ids.reverse.map(&:to_s)

      expect(form).not_to be_changed
    end

    it "is true when the submitted coordinators differ from the current ones" do
      form.coordinator_ids = [ create(:user).id.to_s ]

      expect(form).to be_changed
    end

    it "is true when only the description changes" do
      form.assign_attributes(
        description: "A changed description",
        coordinator_ids: task.coordinator_ids.map(&:to_s)
      )

      expect(form).to be_changed
    end
  end
end
