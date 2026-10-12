require 'rails_helper'

RSpec.describe "Root path", type: :request do
  # Visible: a published initiative with an old and a new published task
  let!(:visible_project) { create(:project, :published) }
  let!(:old_task) do
    create(:task, :published, project: visible_project,
                              created_at: (Task::NEW_TASK_THRESHOLD + 1.day).ago,
                              published_at: 1.week.ago)
  end
  let!(:new_task) { create(:task, :published, project: visible_project) }

  # Hidden: a published task in a draft initiative, an unpublished task in a
  # published initiative, and a published initiative without published tasks
  let!(:task_in_draft_project) { create(:task, :published, :with_unpublished_project) }
  let!(:unpublished_task) { create(:task, :not_published, project: visible_project) }
  let!(:project_without_tasks) { create(:project, :published) }

  def page
    Nokogiri::HTML(response.body)
  end

  def stat(key)
    page.at_css("#home-stats-#{key} > span").text
  end

  shared_examples "shows the counts of visible tasks and initiatives" do
    it "counts only the tasks and initiatives the lists show" do
      get root_path

      expect(stat("open-tasks")).to eq("2")
      expect(stat("initiatives")).to eq("1")
      expect(stat("new-tasks")).to eq("1")
    end

    it "explains how it works" do
      get root_path

      expect(page.css("#home-how-it-works li").size).to eq(3)
    end
  end

  describe "GET /" do
    context "as a visitor" do
      it "loads the root page" do
        get root_path

        expect(response).to have_http_status(:success)
      end

      it "shows the site name and tagline as the title" do
        Site.create!(name: "Acme", tagline: "for everyone")

        get root_path

        expect(page.at_css("title").text).to eq("Acme - for everyone")
      end

      include_examples "shows the counts of visible tasks and initiatives"

      it "doesn't link the counts" do
        get root_path

        expect(page.css("#home-stats a")).to be_empty
      end

      it "doesn't show tasks" do
        get root_path

        expect(page.at_css("#home-recent-tasks")).to be_nil
      end
    end

    context "as a user" do
      let(:user) { create(:user) }

      before { login_as(user) }

      it "loads the root page" do
        get root_path

        expect(response).to have_http_status(:success)
      end

      include_examples "shows the counts of visible tasks and initiatives"

      it "links the counts to the lists" do
        get root_path

        expect(page.at_css("#home-stats-open-tasks")["href"]).to eq(tasks_path)
        expect(page.at_css("#home-stats-initiatives")["href"]).to eq(projects_path)
      end

      it "shows the most recently published visible tasks first" do
        get root_path

        card_ids = page.css("#home-recent-tasks section[id^='task-card-']").map { |card| card["id"] }
        expect(card_ids).to eq([ "task-card-#{new_task.id}", "task-card-#{old_task.id}" ])
      end

      it "shows at most three tasks" do
        create_list(:task, 3, :published, project: visible_project)

        get root_path

        expect(page.css("#home-recent-tasks section[id^='task-card-']").size).to eq(3)
      end
    end

    context "without visible tasks" do
      before { Task.update_all(published_at: nil) }

      it "hides the counts" do
        get root_path

        expect(page.at_css("#home-stats")).to be_nil
      end
    end
  end
end
