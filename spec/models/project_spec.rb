require 'rails_helper'

RSpec.describe Project, type: :model do
  describe "validations" do
    context "with valid attributes" do
      it "is valid" do
        project = create(:project)
        expect(project).to be_valid
      end
    end

    context "when title is too short" do
      it "is invalid with a title of less than 10 characters" do
        project = build(:project, title: "h" * 9)
        expect(project).not_to be_valid
      end
    end

    context "when title is absent" do
      it "is invalid without a title" do
        project = build(:project, title: nil)
        expect(project).not_to be_valid
      end
    end

    context "when description is too short" do
      it "is invalid with a description of less than 10 characters" do
        project = build(:project, description: "h" * 9)
        expect(project).not_to be_valid
      end
    end

    context "when description is absent" do
      it "is invalid without a description" do
        project = build(:project, description: nil)
        expect(project).not_to be_valid
      end
    end
  end

  describe "#published?" do
    context "when published_at date is now" do
      it "returns true" do
        project = build(:project, published_at: Time.zone.now)
        expect(project.published?).to be true
      end
    end

    context "when published_at date is tomorrow" do
      it "return false" do
        project = build(:project, published_at: Time.zone.tomorrow)
        expect(project.published?).to be false
      end
    end

    context "when published_at date is yesterday" do
      it "returns true" do
        project = build(:project, published_at: Time.zone.yesterday)
        expect(project.published?).to be true
      end
    end

    context "when published_at date is nil" do
      it "returns false" do
        project = build(:project, published_at: nil)
        expect(project.published?).to be false
      end
    end
  end

  describe "#publish" do
    context "when publishe(ed)" do
      it "publishes the task" do
        project = create(:project, published_at: nil)
        project.publish
        expect(project).to be_published
      end

      it "is published at the current time" do
        project = create(:project, published_at: nil)
        project.publish
        expect(project.published_at).to be >= Time.zone.now - 10.seconds
        expect(project.published_at).to be <= Time.zone.now + 10.seconds
      end
    end
  end

  describe "#unpublish" do
    context "when unpublish(ed)" do
      it "unpublishes the task" do
        project = create(:project, published_at: Time.zone.yesterday)
        project.unpublish
        expect(project).not_to be_published
      end
    end
  end
end
