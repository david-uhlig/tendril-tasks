# Behaviour shared by the records that have a publication state and coordinators
# (Task, Project). The argument is the factory name of the record:
#
#   it_behaves_like "a publishable record", :task
RSpec.shared_examples "a publishable record" do |record_factory|
  include ActiveSupport::Testing::TimeHelpers

  describe "#published?" do
    it "is true when published right now" do
      record = build(record_factory, published_at: Time.zone.now)
      expect(record).to be_published
    end

    it "is true when published in the past" do
      record = build(record_factory, published_at: Time.zone.today - 1.day)
      expect(record).to be_published
    end

    it "is false when published in the future" do
      record = build(record_factory, published_at: Time.zone.today + 1.day)
      expect(record).not_to be_published
    end

    it "is false when published_at is nil" do
      record = build(record_factory, published_at: nil)
      expect(record).not_to be_published
    end
  end

  describe "#publish" do
    after { travel_back }

    it "publishes the record" do
      record = build(record_factory, :not_published)
      record.publish
      expect(record).to be_published
    end

    it "publishes at the current time" do
      freeze_time

      record = build(record_factory, :not_published)
      record.publish
      expect(record.published_at).to eq(Time.current)
    end

    it "keeps the publication date of a published record" do
      published_at = 1.week.ago.change(usec: 0)
      record = build(record_factory, published_at: published_at)
      record.publish
      expect(record.published_at).to eq(published_at)
    end
  end

  describe "#unpublish" do
    it "unpublishes the record" do
      record = build(record_factory, :published)
      record.unpublish
      expect(record).not_to be_published
    end
  end

  describe "#orphaned?" do
    let(:user) { create(:user) }

    it "is false when the record has coordinators" do
      record = build(record_factory)
      expect(record).not_to be_orphaned
    end

    it "is true when the record has no coordinators" do
      record = create(record_factory, coordinators: [ user ])
      user.destroy
      record.reload
      expect(record).to be_orphaned
    end
  end

  describe ".orphaned" do
    let(:user) { create(:user) }

    it "returns only records without coordinators" do
      orphaned_record = create(record_factory, coordinators: [ user ])
      create(record_factory)
      user.destroy
      expect(described_class.orphaned.to_a).to eq([ orphaned_record ])
    end
  end
end
