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

  describe "#coordinator_ids=" do
    let(:coordinator) { create(:user) }
    let(:task) { create(:task, coordinators: [ coordinator ]) }
    let(:form) { described_class.new(task) }

    it "ignores ids of users that no longer exist" do
      other = create(:user)
      form.coordinator_ids = [ other.id.to_s, "0" ]

      expect(form.coordinators).to eq([ other ])
    end

    it "doesn't treat ids of users that no longer exist as a change" do
      form.coordinator_ids = [ coordinator.id.to_s, "0" ]

      expect(form).not_to be_changed
    end
  end

  describe "#save" do
    let(:coordinator) { create(:user) }
    let(:task) { create(:task, coordinators: [ coordinator ]) }
    let(:form) { described_class.new(task) }

    it "fails validation when all coordinators are removed" do
      form.coordinator_ids = []

      expect(form.save).to be(false)
      expect(form.errors).to include(:coordinators)
      expect(task.reload.coordinators).to eq([ coordinator ])
    end

    it "fails validation when only ids of users that no longer exist are submitted" do
      form.coordinator_ids = [ "0" ]

      expect(form.save).to be(false)
      expect(form.errors).to include(:coordinators)
      expect(task.reload.coordinators).to eq([ coordinator ])
    end

    it "keeps the submitted coordinators after a failed save" do
      other = create(:user)
      form.assign_attributes(title: "", coordinator_ids: [ other.id.to_s ])

      expect(form.save).to be(false)
      expect(form.coordinators).to eq([ other ])
      expect(task.reload.coordinators).to eq([ coordinator ])
    end

    it "records changes to the attributes" do
      form.title = "A changed title"

      expect(form.save).to be(true)
      expect(form).to be_saved_changes
    end

    it "records changes to the coordinators" do
      form.coordinator_ids = [ create(:user).id.to_s ]

      expect(form.save).to be(true)
      expect(form).to be_saved_changes
    end

    it "records no changes when nothing changed" do
      form.assign_attributes(title: task.title, coordinator_ids: [ coordinator.id.to_s ])

      expect(form.save).to be(true)
      expect(form).not_to be_saved_changes
    end

    it "records no changes after a failed save" do
      form.title = "A changed title"
      form.save
      form.title = ""

      expect(form.save).to be(false)
      expect(form).not_to be_saved_changes
    end

    it "replaces the coordinators" do
      other = create(:user)
      form.coordinator_ids = [ other.id.to_s ]

      expect(form.save).to be(true)
      expect(task.reload.coordinators).to eq([ other ])
    end
  end

  describe "#publish=" do
    it "publishes an unpublished task" do
      form = described_class.new(create(:task, :not_published))

      form.publish = "1"

      expect(form.task).to be_published
    end

    it "keeps the publication date of a published task" do
      task = create(:task, :published)
      form = described_class.new(task)

      expect { form.publish = "1" }.not_to change(task, :published_at)
    end

    it "unpublishes a published task" do
      form = described_class.new(create(:task, :published))

      form.publish = "0"

      expect(form.task).not_to be_published
    end
  end

  describe "#publish" do
    it "is true for a published task" do
      expect(described_class.new(create(:task, :published)).publish).to be(true)
    end

    it "is false for an unpublished task" do
      expect(described_class.new(create(:task, :not_published)).publish).to be(false)
    end
  end
end
