# Behaviour shared by the forms that wrap a record with coordinators and a
# publication state (ProjectForm, TaskForm). The argument is the factory name
# of the wrapped record:
#
#   it_behaves_like "a coordinated record form", :task
RSpec.shared_examples "a coordinated record form" do |record_factory|
  describe "#changed?" do
    let(:record) { create(record_factory, coordinators: create_list(:user, 2)) }
    let(:form) { described_class.new(record) }

    it "is false when the submitted coordinators match the current ones" do
      form.coordinator_ids = record.coordinator_ids.reverse.map(&:to_s)

      expect(form).not_to be_changed
    end

    it "is true when the submitted coordinators differ from the current ones" do
      form.coordinator_ids = [ create(:user).id.to_s ]

      expect(form).to be_changed
    end

    it "is true when only the description changes" do
      form.assign_attributes(
        description: "A changed description that is long enough!",
        coordinator_ids: record.coordinator_ids.map(&:to_s)
      )

      expect(form).to be_changed
    end
  end

  describe "#coordinator_ids=" do
    let(:coordinator) { create(:user) }
    let(:record) { create(record_factory, coordinators: [ coordinator ]) }
    let(:form) { described_class.new(record) }

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

  describe "#valid?" do
    it "is true when the record is valid" do
      expect(described_class.new(create(record_factory)).valid?).to be(true)
    end

    it "is false and reports the record's errors when the record is invalid" do
      form = described_class.new(create(record_factory))
      form.title = ""

      expect(form.valid?).to be(false)
      expect(form.errors[:title]).to be_present
    end
  end

  describe "#save" do
    let(:coordinator) { create(:user) }
    let(:record) { create(record_factory, coordinators: [ coordinator ]) }
    let(:form) { described_class.new(record) }

    it "fails validation when all coordinators are removed" do
      form.coordinator_ids = []

      expect(form.save).to be(false)
      expect(form.errors).to include(:coordinators)
      expect(record.reload.coordinators).to eq([ coordinator ])
    end

    it "fails validation when only ids of users that no longer exist are submitted" do
      form.coordinator_ids = [ "0" ]

      expect(form.save).to be(false)
      expect(form.errors).to include(:coordinators)
      expect(record.reload.coordinators).to eq([ coordinator ])
    end

    it "keeps the submitted coordinators after a failed save" do
      other = create(:user)
      form.assign_attributes(title: "", coordinator_ids: [ other.id.to_s ])

      expect(form.save).to be(false)
      expect(form.coordinators).to eq([ other ])
      expect(record.reload.coordinators).to eq([ coordinator ])
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
      form.assign_attributes(title: record.title, coordinator_ids: [ coordinator.id.to_s ])

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
      expect(record.reload.coordinators).to eq([ other ])
    end
  end

  describe "#publish=" do
    it "publishes an unpublished record" do
      record = create(record_factory, :not_published)
      form = described_class.new(record)

      form.publish = "1"

      expect(record).to be_published
    end

    it "keeps the publication date of a published record" do
      record = create(record_factory, :published)
      form = described_class.new(record)

      expect { form.publish = "1" }.not_to change(record, :published_at)
    end

    it "unpublishes a published record" do
      record = create(record_factory, :published)
      form = described_class.new(record)

      form.publish = "0"

      expect(record).not_to be_published
    end
  end

  describe "#publish" do
    it "is true for a published record" do
      expect(described_class.new(create(record_factory, :published)).publish).to be(true)
    end

    it "is false for an unpublished record" do
      expect(described_class.new(create(record_factory, :not_published)).publish).to be(false)
    end
  end

  describe "#form_method" do
    it "is patch for a persisted record" do
      expect(described_class.new(create(record_factory)).form_method).to eq(:patch)
    end

    it "is post for a new record" do
      expect(described_class.new.form_method).to eq(:post)
    end
  end
end
