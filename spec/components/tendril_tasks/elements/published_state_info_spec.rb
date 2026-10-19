require "rails_helper"

RSpec.describe TendrilTasks::Elements::PublishedStateInfo, type: :component do
  context "with a task" do
    it "shows the published state for a published task" do
      task = create(:task, :published, :with_published_project)

      render_inline(described_class.new(task))

      expect(page).to have_text("Veröffentlicht")
      expect(page).to have_no_text("Entwurf")
    end

    it "shows the draft state for an unpublished task" do
      task = create(:task, :not_published, :with_published_project)

      render_inline(described_class.new(task))

      expect(page).to have_text("Entwurf")
      expect(page).to have_no_text("Veröffentlicht")
    end

    it "shows the draft state for a task scheduled to be published later" do
      task = create(:task, published_at: 1.day.from_now, project: create(:project, :published))

      render_inline(described_class.new(task))

      expect(page).to have_text("Entwurf")
      expect(page).to have_no_text("Veröffentlicht")
    end
  end

  context "with a project" do
    it "shows the published state for a published project" do
      project = create(:project, :published)

      render_inline(described_class.new(project))

      expect(page).to have_text("Veröffentlicht")
    end

    it "shows the draft state for an unpublished project" do
      project = create(:project, :not_published)

      render_inline(described_class.new(project))

      expect(page).to have_text("Entwurf")
      expect(page).to have_no_text("Veröffentlicht")
    end
  end
end
