require "rails_helper"

RSpec.describe TendrilTasks::Elements::VisibilityStateInfo, type: :component do
  context "with a task" do
    it "shows visible for a published task in a published project" do
      task = create(:task, :published, :with_published_project)

      render_inline(described_class.new(task))

      expect(page).to have_text("Sichtbar")
      expect(page).to have_no_text("Versteckt")
    end

    it "shows hidden for a published task in an unpublished project" do
      task = create(:task, :published, :with_unpublished_project)

      render_inline(described_class.new(task))

      expect(page).to have_text("Versteckt")
      expect(page).to have_no_text("Sichtbar")
    end

    it "shows hidden for an unpublished task" do
      task = create(:task, :not_published, :with_published_project)

      render_inline(described_class.new(task))

      expect(page).to have_text("Versteckt")
      expect(page).to have_no_text("Sichtbar")
    end
  end

  context "with a project" do
    it "shows visible for a published project with a published task" do
      project = create(:project, :published, :with_published_tasks, tasks_count: 1)

      render_inline(described_class.new(project))

      expect(page).to have_text("Sichtbar")
      expect(page).to have_no_text("Versteckt")
    end

    it "shows hidden for a published project without any published task" do
      project = create(:project, :published, :with_unpublished_tasks, tasks_count: 1)

      render_inline(described_class.new(project))

      expect(page).to have_text("Versteckt")
      expect(page).to have_no_text("Sichtbar")
    end

    it "shows hidden for an unpublished project with a published task" do
      project = create(:project, :not_published, :with_published_tasks, tasks_count: 1)

      render_inline(described_class.new(project))

      expect(page).to have_text("Versteckt")
      expect(page).to have_no_text("Sichtbar")
    end
  end
end
