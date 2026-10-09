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
end
