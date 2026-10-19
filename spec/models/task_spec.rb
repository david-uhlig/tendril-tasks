require 'rails_helper'

RSpec.describe Task, type: :model do
  context "with valid attributes" do
    it "is valid" do
      task = build(:task)
      expect(task).to be_valid
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

  it_behaves_like "a publishable record", :task

  describe "#publicly_visible" do
    it "returns published tasks with published projects" do
      published_task_with_published_project = create(:task, :published, :with_published_project)
      create(:task, :published)
      create(:task, :not_published)
      expect(Task.publicly_visible).to eq([ published_task_with_published_project ])
    end
  end

  describe "#is_published" do
    it "returns published tasks" do
      published_task = create(:task, :published)
      create(:task, :not_published)
      expect(Task.is_published).to eq([ published_task ])
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
