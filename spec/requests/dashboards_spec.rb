require "rails_helper"

RSpec.describe "User Dashboard", type: :request do
  let(:user) { create(:user) }

  describe "GET /dashboard" do
    it "requires authentication" do
      require_authentication_for { get dashboard_path }
    end

    context "when authenticated" do
      before(:each) { login_as(user) }

      it "displays the user's dashboard" do
        get dashboard_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include(I18n.t("dashboards.show.title"))
      end

      it "shows the placeholder when the user has no applications" do
        get dashboard_path

        expect(response.body).to include(I18n.t("dashboards.show.applications_placeholder"))
      end

      it "lists the user's applications by task title", :aggregate_failures do
        create(:task_application, user: user, task: create(:task, :published, :with_published_project, title: "Water the plants"))
        create(:task_application, user: user, task: create(:task, :published, :with_published_project, title: "Feed the cat"))

        get dashboard_path

        expect(response.body).to include("Water the plants", "Feed the cat")
        expect(response.body).not_to include(I18n.t("dashboards.show.applications_placeholder"))
      end

      it "does not list withdrawn applications", :aggregate_failures do
        create(:task_application, user: user, status: :withdrawn,
               task: create(:task, :published, :with_published_project, title: "Withdrawn task"))
        create(:task_application, user: user,
               task: create(:task, :published, :with_published_project, title: "Active task"))

        get dashboard_path

        expect(response.body).to include("Active task")
        expect(response.body).not_to include("Withdrawn task")
      end

      it "shows the placeholder when the only applications are withdrawn" do
        create(:task_application, user: user, status: :withdrawn,
               task: create(:task, :published, :with_published_project, title: "Withdrawn task"))

        get dashboard_path

        expect(response.body).to include(I18n.t("dashboards.show.applications_placeholder"))
        expect(response.body).not_to include("Withdrawn task")
      end

      it "does not list applications of other users", :aggregate_failures do
        create(:task_application, user: create(:user),
               task: create(:task, :published, :with_published_project, title: "Someone else's task"))

        get dashboard_path

        expect(response.body).not_to include("Someone else's task")
        expect(response.body).to include(I18n.t("dashboards.show.applications_placeholder"))
      end

      it "lists applications newest first" do
        create(:task_application, user: user, created_at: 2.days.ago,
               task: create(:task, :published, :with_published_project, title: "Oldest application"))
        create(:task_application, user: user, created_at: 1.hour.ago,
               task: create(:task, :published, :with_published_project, title: "Newest application"))
        create(:task_application, user: user, created_at: 1.day.ago,
               task: create(:task, :published, :with_published_project, title: "Middle application"))

        get dashboard_path

        titles = Nokogiri::HTML(response.body).css("ol.space-y-4 li h3").map { |heading| heading.text.strip }
        expect(titles).to eq([ "Newest application", "Middle application", "Oldest application" ])
      end
    end
  end
end
