require 'rails_helper'

RSpec.describe Task, type: :model do
  context "with valid attributes" do
    it "is valid" do
      task = build(:task)
      expect(task).to be_valid
    end

    it "is valid with a title of 10+ characters" do
      task = build(:task, title: "a" * 10)
      expect(task).to be_valid
    end

    it "is valid with a title of a single character" do
      task = build(:task, title: "a")
      expect(task).to be_valid
    end

    it "is valid with a description of 10+ characters" do
      task = build(:task, description: "a" * 10)
      expect(task).to be_valid
    end

    it "is valid with a description of a single character" do
      task = build(:task, description: "a")
      expect(task).to be_valid
    end

    it "persists" do
      task = create(:task)
      expect(task).to be_persisted
    end
  end

  context "with invalid attributes" do
    it "is invalid without a title" do
      task = build(:task, title: nil)
      expect(task).not_to be_valid
    end

    it "is invalid without a description" do
      task = build(:task, description: nil)
      expect(task).not_to be_valid
    end

    it "is invalid without a project" do
      task = build(:task, project: nil)
      expect(task).not_to be_valid
    end

    it "is invalid without a coordinator" do
      task = build(:task, :without_coordinators)
      expect(task).not_to be_valid
    end
  end

  describe "#published?" do
    context "when published_at date is now" do
      it "returns true" do
        task = build(:task, published_at: Time.zone.now)
        expect(task.published?).to be true
      end
    end

    context "when published_at date is in the past" do
      it "returns true" do
        task = build(:task, published_at: Time.zone.today - 1.day)
        expect(task.published?).to be true
      end
    end

    context "when published_at date is in the future" do
      it "returns false" do
        task = build(:task, published_at: Time.zone.today + 1.day)
        expect(task.published?).to be false
      end
    end

    context "when published_at date is nil" do
      it "returns false" do
        task = build(:task, published_at: nil)
        expect(task.published?).to be false
      end
    end
  end

  describe "#publish" do
    it "publishes the task" do
      task = build(:task, :not_published)
      task.publish
      expect(task).to be_published
    end

    it "publishes at the current time" do
      task = build(:task, :not_published)
      task.publish
      expect(task.published_at).to be >= Time.zone.now - 10.seconds
      expect(task.published_at).to be <= Time.zone.now + 10.seconds
    end
  end

  describe "#unpublish" do
    it "unpublishes the task" do
      task = build(:task, :published)
      task.unpublish
      expect(task).not_to be_published
    end
  end

  describe "#visible?" do
    context "when task and project are published" do
      it "returns true" do
        task = build(:task, :published, :with_published_project)
        expect(task).to be_visible
      end
    end

    context "when task is not published" do
      it "returns false" do
        task = build(:task, :not_published)
        expect(task).not_to be_visible
      end
    end

    context "when project is not published" do
      it "returns false" do
        task = build(:task, :published, :with_unpublished_project)
        expect(task).not_to be_visible
      end
    end
  end
end
