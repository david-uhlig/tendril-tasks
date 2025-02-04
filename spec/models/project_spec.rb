require 'rails_helper'

RSpec.describe Project, type: :model do
  describe "with valid attributes" do
    it "is valid" do
      project = create(:project)
      expect(project).to be_valid
    end
  end

  describe "with invalid attributes" do
    it "is invalid without a title" do
      project = build(:project, title: nil)
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

  describe ".orphaned" do
    let(:user) { create(:user) }

    it "returns projects without coordinators" do
      project_without_coordinator = create(
        :project, coordinators: [ user ]
      )
      create(:project)
      user.destroy
      expect(Project.orphaned.to_a).to eq([ project_without_coordinator ])
    end
  end

  describe "#orphaned?" do
    let(:user) { create(:user) }

    context "when project has coordinators" do
      it "is not orphaned" do
        project = build(:project)
        expect(project).not_to be_orphaned
      end
    end

    context "when project has no coordinators" do
      it "is orphaned" do
        project = create(:project, coordinators: [ user ])
        user.destroy
        project.reload
        expect(project).to be_orphaned
      end
    end
  end

  describe "#published?" do
    context "with default values" do
      it "is not published" do
        project = build(:project)
        expect(project).not_to be_published
      end
    end

    context "when published_at is unspecified" do
      it "is not published" do
        project = build(:project, published_at: nil)
        expect(project).not_to be_published
      end
    end

    context "when published in the future" do
      it "is not published" do
        project = build(:project, published_at: Time.zone.tomorrow)
        expect(project).not_to be_published
      end
    end

    context "when published right now" do
      it "is published" do
        project = build(:project, published_at: Time.zone.now)
        expect(project).to be_published
      end
    end

    context "when published in the past" do
      it "is published" do
        project = build(:project, published_at: Time.zone.yesterday)
        expect(project).to be_published
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

  describe "#publicly_visible" do
    it "returns published projects with published tasks" do
      published_project_with_published_task = create(
        :project, :published, :with_published_tasks
      )
      create(:project, :published, :with_unpublished_tasks)
      create(:project, :not_published)
      expect(Project.publicly_visible).to eq([ published_project_with_published_task ])
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
