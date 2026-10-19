require "rails_helper"

RSpec.describe TendrilTasks::Dashboard::Application, type: :component do
  let(:user) { create(:user) }
  let(:task) do
    create(:task, :published, :with_published_project,
           title: "Water the plants")
  end
  let(:application) { create(:task_application, user: user, task: task, comment: "I can do it on Mondays") }

  it "links the title to the task and is not greyed out when the task is visible" do
    render_inline(described_class.new(application))

    expect(page).to have_link("Water the plants", href: "/tasks/#{task.id}")
    expect(page).to have_no_css(".grayscale")
    expect(page).to have_no_text("Nicht verfügbar")
  end

  it "shows the application date and comment" do
    render_inline(described_class.new(application))

    expect(page).to have_text(I18n.t("task_application.applied_on_date", date: I18n.l(application.created_at, format: :long)))
    expect(page).to have_text("I can do it on Mondays")
  end

  it "offers to edit the application on the task page when the task is visible" do
    render_inline(described_class.new(application))

    expect(page).to have_link(href: "/tasks/#{task.id}#apply-now")
  end

  context "when the task is not published" do
    let(:task) do
      create(:task, :not_published, :with_published_project, title: "Water the plants")
    end

    it "shows the title without a link and greys out the application" do
      render_inline(described_class.new(application))

      expect(page).to have_text("Water the plants")
      expect(page).to have_no_link("Water the plants")
      expect(page).to have_css(".grayscale")
    end

    it "marks the task as not available and offers no edit link" do
      render_inline(described_class.new(application))

      expect(page).to have_text("Nicht verfügbar")
      expect(page).to have_no_link(href: "/tasks/#{task.id}#apply-now")
    end
  end

  context "when the task's project is not published" do
    let(:task) do
      create(:task, :published, :with_unpublished_project, title: "Water the plants")
    end

    it "shows the title without a link and greys out the application" do
      render_inline(described_class.new(application))

      expect(page).to have_text("Water the plants")
      expect(page).to have_no_link("Water the plants")
      expect(page).to have_css(".grayscale")
    end
  end
end
