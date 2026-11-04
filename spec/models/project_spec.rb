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

  it_behaves_like "a publishable record", :project

  describe "#order_by_most_recently_published_task" do
    it "returns an empty array when there are no projects" do
      expect(Project.order_by_most_recently_published_task).to eq([])
    end

    it "returns an empty array when there are no published tasks" do
      create(:project, :published)
      create(:project, :published)
      expect(Project.order_by_most_recently_published_task).to eq([])
    end

    it "returns projects ordered by the most recently published task" do
      oldest_project = create(:project, :published, title: "Oldest Project")
      newest_project = create(:project, :published, title: "Newest Project")
      create(:task, :published, project: newest_project)
      create(:task, :published, project: oldest_project)
      expect(Project.order_by_most_recently_published_task).to eq([ oldest_project, newest_project ])
    end

    it "unpublished tasks do not affect the order" do
      oldest_project = create(:project, :published, title: "Oldest Project")
      newest_project = create(:project, :published, title: "Newest Project")
      create(:task, :published, project: newest_project)
      create(:task, :published, project: oldest_project)
      create(:task, :not_published, project: newest_project)
      expect(Project.order_by_most_recently_published_task).to eq([ oldest_project, newest_project ])
    end

    it "orders by the latest published task of each project" do
      project_a = create(:project, :published)
      project_b = create(:project, :published)
      create(:task, project: project_a, published_at: 3.days.ago)
      create(:task, project: project_b, published_at: 2.days.ago)
      create(:task, project: project_a, published_at: 1.day.ago)
      expect(Project.order_by_most_recently_published_task).to eq([ project_a, project_b ])
    end

    it "scheduled tasks do not affect the order" do
      project_a = create(:project, :published)
      project_b = create(:project, :published)
      create(:task, project: project_a, published_at: 1.day.ago)
      create(:task, project: project_b, published_at: 2.days.ago)
      create(:task, project: project_b, published_at: 1.day.from_now)
      expect(Project.order_by_most_recently_published_task).to eq([ project_a, project_b ])
    end

    it "returns each project once" do
      project = create(:project, :published, :with_published_tasks)
      expect(Project.order_by_most_recently_published_task).to eq([ project ])
    end

    it "combines with publicly_visible" do
      project_a = create(:project, :published)
      project_b = create(:project, :published)
      create(:task, project: project_a, published_at: 2.days.ago)
      create(:task, project: project_b, published_at: 1.day.ago)
      projects = Project.publicly_visible.order_by_most_recently_published_task
      expect(projects).to eq([ project_b, project_a ])
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

  describe "publication date in the future" do
    include ActiveSupport::Testing::TimeHelpers

    let(:publish_at) { 1.day.from_now.change(usec: 0) }

    it "excludes projects published in the future from published" do
      project = create(:project, published_at: publish_at)
      expect(Project.published).not_to include(project)
    end

    it "includes projects published in the future in published once that time has passed" do
      project = create(:project, published_at: publish_at)
      travel_to(publish_at + 1.second) do
        expect(Project.published).to include(project)
      end
    end

    it "excludes projects published in the future from publicly_visible" do
      project = create(:project, :with_published_tasks, published_at: publish_at)
      expect(Project.publicly_visible).not_to include(project)
    end

    it "includes projects published in the future in publicly_visible once that time has passed" do
      project = create(:project, :with_published_tasks, published_at: publish_at)
      travel_to(publish_at + 1.second) do
        expect(Project.publicly_visible).to include(project)
      end
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
