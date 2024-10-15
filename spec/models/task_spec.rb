require 'rails_helper'

RSpec.describe Task, type: :model do
  describe "validations" do
    context "with valid attributes" do
      it "is valid" do
        task = create(:task)
        expect(task).to be_valid
      end
    end

    context "when title is too short" do
      it "is invalid with a title of less than 10 characters" do
        task = build(:task, title: "a" * 9)
        expect(task).not_to be_valid
      end
    end

    context "when title is absent" do
      it "is invalid without a title" do
        task = build(:task, title: nil)
        expect(task).not_to be_valid
      end
    end

    context "when description is too short" do
      it "is invalid with a description of less than 10 characters" do
        task = build(:task, description: "a" * 9)
        expect(task).not_to be_valid
      end
    end

    context "when description is absent" do
      it "is invalid without a description" do
        task = build(:task, description: nil)
        expect(task).not_to be_valid
      end
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
    context "when publish(ed)" do
      it "publishes the task" do
        task = build(:task, published_at: nil)
        task.publish
        expect(task).to be_published
      end

      it "is published at the current time" do
        task = build(:task, published_at: nil)
        task.publish
        expect(task.published_at).to be >= Time.zone.now - 10.seconds
        expect(task.published_at).to be <= Time.zone.now + 10.seconds
      end
    end
  end

  describe "#unpublish" do
    context "when unpublish(ed)" do
      it "unpublishes the task" do
        task = build(:task, published_at: Time.zone.yesterday)
        task.unpublish
        expect(task).not_to be_published
      end
    end
  end
end
