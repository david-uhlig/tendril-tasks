require 'rails_helper'

RSpec.describe "Tasks", type: :request do
  context "when logged out" do
    it "GET /tasks redirects to new_user_session_path" do
      get tasks_path
      expect(response).to redirect_to(new_user_session_path)
      expect(response).to have_http_status(:found)
    end

    it "POST /tasks redirects to new_user_session_path" do
      post tasks_path
      expect(response).to redirect_to(new_user_session_path)
      expect(response).to have_http_status(:found)
    end

    it "GET /tasks/new redirects to new_user_session_path" do
      get new_task_path
      expect(response).to redirect_to(new_user_session_path)
      expect(response).to have_http_status(:found)
    end

    it "GET /tasks/new/from-preset/:project_id/:coordinator_ids redirects to new_user_session_path" do
      project = create(:project)
      coordinator = create(:user)

      get new_task_with_preset_path(project_id: project.id, coordinator_ids: [ coordinator.id ])
      expect(response).to redirect_to(new_user_session_path)
      expect(response).to have_http_status(:found)
    end

    it "GET /tasks/:id/edit redirects to new_user_session_path" do
      task = create(:task)

      get edit_task_path(task)
      expect(response).to redirect_to(new_user_session_path)
      expect(response).to have_http_status(:found)
    end

    it "GET /tasks/:id redirects to new_user_session_path" do
      task = create(:task)

      get task_path(task)
      expect(response).to redirect_to(new_user_session_path)
      expect(response).to have_http_status(:found)
    end

    it "PATCH /tasks/:id redirects to new_user_session_path" do
      task = create(:task)

      patch task_path(task)
      expect(response).to redirect_to(new_user_session_path)
      expect(response).to have_http_status(:found)
    end

    it "PUT /tasks/:id redirects to new_user_session_path" do
      task = create(:task)

      put task_path(task)
      expect(response).to redirect_to(new_user_session_path)
      expect(response).to have_http_status(:found)
    end

    it "DELETE /tasks/:id redirects to new_user_session_path " do
      task = create(:task)

      delete task_path(task)
      expect(response).to redirect_to(new_user_session_path)
      expect(response).to have_http_status(:found)
    end
  end

  context "when logged in as user" do
    let(:user) { create(:user) }

    before(:each) { login_as(user, scope: :user) }

    it "returns http success on GET /tasks" do
      get "/tasks"
      expect(response).to have_http_status(:success)
    end

    it "fails to access tasks of unpublished project" do
      project = create(:project, :not_published, :with_published_tasks)

      get "/projects/#{project.id}/tasks"
      expect(response).to have_http_status(:not_found)
    end

    it "fails to access project with unpublished tasks" do
      project = create(:project, :published, :with_unpublished_tasks)

      get "/projects/#{project.id}/tasks"
      expect(response).to have_http_status(:not_found)
    end

    it "can access published project with published tasks" do
      project = create(:project, :published, :with_published_tasks)

      get "/projects/#{project.id}/tasks"
      expect(response).to have_http_status(:success)
    end
  end
end
