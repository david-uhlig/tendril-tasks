require "rails_helper"

RSpec.describe TendrilTasks::Elements::VisibilityInfoBar, type: :component do
  let(:coordinator) { create(:user) }
  let(:project) { create(:project, :published, coordinators: [ coordinator ]) }
  let(:task) do
    create(:task, :published, project: project, coordinators: [ coordinator ])
  end

  context "when the user can coordinate the element" do
    before { as(coordinator) }

    it "shows the published state of a published task" do
      render_inline(described_class.new(task))

      expect(page).to have_text("Veröffentlicht")
    end

    it "shows the visibility state of a task" do
      render_inline(described_class.new(task))

      expect(page).to have_text("Sichtbar")
    end

    it "shows the draft and hidden states of an unpublished task" do
      task.update!(published_at: nil)

      render_inline(described_class.new(task))

      expect(page).to have_text("Entwurf")
      expect(page).to have_text("Versteckt")
    end

    it "shows the published and visibility states of a project" do
      render_inline(described_class.new(project))

      expect(page).to have_text("Veröffentlicht")
      expect(page).to have_text("Versteckt")
    end
  end

  context "when the user cannot coordinate the element" do
    before { as(create(:user)) }

    it "renders nothing for a task" do
      render_inline(described_class.new(task))

      expect(rendered_content).to be_blank
    end

    it "renders nothing for a project" do
      render_inline(described_class.new(project))

      expect(rendered_content).to be_blank
    end
  end
end
