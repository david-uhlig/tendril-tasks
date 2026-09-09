require "rails_helper"

RSpec.describe "Coordinator Searches", type: :request do
  let(:user) { create(:user) }
  let(:editor) { create(:user, :editor) }

  describe "GET /coordinators/search" do
    it "requires authentication" do
      require_authentication_for {
        get coordinators_searches_path, as: :turbo_stream
      }
    end

    context "when authenticated" do
      it "unauthorized access is forbidden" do
        login_as(user)
        get coordinators_searches_path, as: :turbo_stream
        expect(response).to have_http_status(:forbidden)
      end

      it "project coordinators can view search results" do
        login_as(user)
        project = create(:project, coordinators: [ user ])
        get coordinators_searches_path, as: :turbo_stream
        expect(response).to have_http_status(:success)
      end

      it "task coordinators can view search results" do
        login_as(user)
        task = create(:task, coordinators: [ user ])
        get coordinators_searches_path, as: :turbo_stream
        expect(response).to have_http_status(:success)
      end

      # Requires editor role or above.
      it "authorized users can view search results" do
        login_as(editor)
        get coordinators_searches_path, as: :turbo_stream
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "POST /coordinators/search" do
    it "requires authentication" do
      require_authentication_for {
        post coordinators_searches_path, as: :turbo_stream
      }
    end

    context "when authenticated" do
      it "unauthorized access is forbidden" do
        login_as(user)
        post coordinators_searches_path, as: :turbo_stream
        expect(response).to have_http_status(:forbidden)
      end

      it "project coordinators can assign the coordinator selection" do
        login_as(user)
        project = create(:project, coordinators: [ user ])
        post coordinators_searches_path, params: { coordinator_ids: [ user.id ] }, as: :turbo_stream
        expect(response).to have_http_status(:success)
        expect(response.body).to include(user.name)
      end

      # Requires editor role or above.
      it "authorized users can assign the coordinator selection" do
        login_as(editor)
        post coordinators_searches_path, params: { coordinator_ids: [ user.id ] }, as: :turbo_stream
        expect(response).to have_http_status(:success)
        expect(response.body).to include(user.name)
      end
    end
  end
end
