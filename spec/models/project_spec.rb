require 'rails_helper'

RSpec.describe Project, type: :model do
  describe "with valid attributes" do
    it "is valid" do
      project = create(:project)
      expect(project).to be_valid
    end
  end

  describe "with invalid attributes" do
    it "is invalid with a title of less than 10 characters" do
      project = build(:project, title: "h" * 9)
      expect(project).not_to be_valid
    end

    it "is invalid without a title" do
      project = build(:project, title: nil)
      expect(project).not_to be_valid
    end

    it "is invalid with a description of less than 10 characters" do
      project = build(:project, description: "h" * 9)
      expect(project).not_to be_valid
    end

    it "is invalid without a description" do
      project = build(:project, description: nil)
      expect(project).not_to be_valid
    end

    it "is invalid without a coordinator" do
      project = build(:project, :without_coordinators)
      expect(project).not_to be_valid
    end
  end

  describe "#published?" do
    context "with default values" do
      it "returns false" do
        project = build(:project)
        expect(project).not_to be_published
      end
    end

    context "when published_at date is now" do
      it "returns true" do
        project = build(:project, published_at: Time.zone.now)
        expect(project).to be_published
      end
    end

    context "when published_at date is tomorrow" do
      it "return false" do
        project = build(:project, published_at: Time.zone.tomorrow)
        expect(project).not_to be_published
      end
    end

    context "when published_at date is yesterday" do
      it "returns true" do
        project = build(:project, published_at: Time.zone.yesterday)
        expect(project).to be_published
      end
    end

    context "when published_at date is nil" do
      it "returns false" do
        project = build(:project, :not_published)
        expect(project).not_to be_published
      end
    end
  end

  describe "#publish" do
    it "publishes the task" do
      project = build(:project, :not_published)
      project.publish
      expect(project).to be_published
    end

    it "publishes at the current time" do
      project = build(:project, :not_published)
      project.publish
      expect(project.published_at).to be >= Time.zone.now - 10.seconds
      expect(project.published_at).to be <= Time.zone.now + 10.seconds
    end
  end

  describe "#unpublish" do
    it "unpublishes the task" do
      project = build(:project, :published)
      project.unpublish
      expect(project).not_to be_published
    end
  end

  describe "#visible?" do
    context "when project is published and has published tasks" do
      it "returns true" do
        project = build_stubbed(:project, :published, :with_published_tasks)
        expect(project).to be_visible
      end
    end

    context "when project is published and has no published tasks" do
      it "returns false" do
        project = build_stubbed(:project, :published)
        expect(project).not_to be_visible
      end
    end

    context "when project is not published" do
      it "returns false" do
        project = build(:project)
        expect(project).not_to be_visible
      end
    end
  end
end
