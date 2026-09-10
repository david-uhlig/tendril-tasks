require "rails_helper"

RSpec.describe "Task application state", type: :request do
  let(:user) { create(:user) }

  before do
    login_as(user)
  end

  describe "GET /tasks/:id" do
    context "when the user has not applied" do
      let!(:task) { create(:task, :published, :with_published_project) }

      it "renders the application form" do
        get task_path(task)

        expect(response).to have_http_status(:success)
        expect(response.body).to include("Interessiert? Hier melden!")
        expect(response.body).to include("Meldung absenden")
        expect(response.body).to include("task_application_comment")
      end
    end

    context "when the user has an editable application" do
      let!(:application) do
        create(
          :task_application,
          user: user,
          comment: "Ein toller Kommentar ist das."
        )
      end

      let(:task) { application.task }

      it "renders the edit application form" do
        get task_path(task)

        expect(response).to have_http_status(:success)
        expect(response.body).to include("Vielen Dank für deine Meldung!")
        expect(response.body).to include("Ein toller Kommentar ist das.")
        expect(response.body).to include("Meldung bearbeiten")
        expect(response.body).to include("Meldung zurückziehen")
      end
    end

    context "when the grace period has expired" do
      let!(:application) do
        create(
          :task_application,
          user: user,
          comment: "Comment create before grace period",
          created_at: (TaskApplication::GRACE_PERIOD + 1.minute).ago
        )
      end

      let(:task) { application.task }

      it "renders the withdrawal-only form" do
        get task_path(task)

        expect(response).to have_http_status(:success)
        expect(response.body).to include("Vielen Dank für deine Meldung!")
        expect(response.body).to include("Comment create before grace period")
        expect(response.body).to include("Meldung zurückziehen")
        expect(response.body).not_to include("Meldung bearbeiten")
        expect(response.body).to include('disabled="disabled"')
      end
    end
  end
end
