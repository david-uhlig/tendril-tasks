require "rails_helper"

RSpec.describe ProjectForm do
  describe "#changed?" do
    let(:project) { create(:project, coordinators: create_list(:user, 2)) }
    let(:form) { described_class.new(project) }

    it "is false when the submitted coordinators match the current ones" do
      form.coordinator_ids = project.coordinator_ids.reverse.map(&:to_s)

      expect(form).not_to be_changed
    end

    it "is true when the submitted coordinators differ from the current ones" do
      form.coordinator_ids = [ create(:user).id.to_s ]

      expect(form).to be_changed
    end

    it "is true when only the description changes" do
      form.assign_attributes(
        description: "A changed description that is long enough!",
        coordinator_ids: project.coordinator_ids.map(&:to_s)
      )

      expect(form).to be_changed
    end
  end

  describe "#coordinator_ids=" do
    let(:coordinator) { create(:user) }
    let(:project) { create(:project, coordinators: [ coordinator ]) }
    let(:form) { described_class.new(project) }

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
    let(:project) { create(:project, coordinators: [ coordinator ]) }
    let(:form) { described_class.new(project) }

    it "fails validation when all coordinators are removed" do
      form.coordinator_ids = []

      expect(form.save).to be(false)
      expect(form.errors).to include(:coordinators)
      expect(project.reload.coordinators).to eq([ coordinator ])
    end

    it "fails validation when only ids of users that no longer exist are submitted" do
      form.coordinator_ids = [ "0" ]

      expect(form.save).to be(false)
      expect(form.errors).to include(:coordinators)
      expect(project.reload.coordinators).to eq([ coordinator ])
    end

    it "keeps the submitted coordinators after a failed save" do
      other = create(:user)
      form.assign_attributes(title: "", coordinator_ids: [ other.id.to_s ])

      expect(form.save).to be(false)
      expect(form.coordinators).to eq([ other ])
      expect(project.reload.coordinators).to eq([ coordinator ])
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
      form.assign_attributes(title: project.title, coordinator_ids: [ coordinator.id.to_s ])

      expect(form.save).to be(true)
      expect(form).not_to be_saved_changes
    end

    it "replaces the coordinators" do
      other = create(:user)
      form.coordinator_ids = [ other.id.to_s ]

      expect(form.save).to be(true)
      expect(project.reload.coordinators).to eq([ other ])
    end
  end
end
