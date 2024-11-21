require 'rails_helper'

RSpec.describe "Tasks", type: :request do
  context "when logged out" do
    it "GET /tasks redirects to root_path" do
      get tasks_path
      expect(response).to redirect_to(root_path)
      expect(response).to have_http_status(:found)
    end

    it "POST /tasks redirects to tasks_path" do
      post tasks_path
      expect(response).to redirect_to(tasks_path)
      expect(response).to have_http_status(:found)
    end

    it "GET /tasks/new redirects to tasks_path" do
      get new_task_path
      expect(response).to redirect_to(tasks_path)
      expect(response).to have_http_status(:found)
    end

    it "GET /tasks/new/from-preset/:project_id/:coordinator_ids redirects to tasks_path" do
      project = create(:project)
      coordinator = create(:user)

      get new_task_with_preset_path(project_id: project.id, coordinator_ids: [ coordinator.id ])
      expect(response).to redirect_to(tasks_path)
      expect(response).to have_http_status(:found)
    end

    it "GET /tasks/:id/edit returns :not_found" do
      task = create(:task)

      get edit_task_path(task)
      expect(response).to have_http_status(:not_found)
    end

    it "GET /tasks/:id returns :not_found" do
      task = create(:task)

      get task_path(task)
      expect(response).to have_http_status(:not_found)
    end

    it "PATCH /tasks/:id returns :not_found" do
      task = create(:task)

      patch task_path(task)
      expect(response).to have_http_status(:not_found)
    end

    it "PUT /tasks/:id returns :not_found" do
      task = create(:task)

      put task_path(task)
      expect(response).to have_http_status(:not_found)
    end

    it "DELETE /tasks/:id" do
      task = create(:task)

      get task_path(task)
      expect(response).to have_http_status(:not_found)
    end
  end

  context "when logged in as user" do
    let(:user) { create(:user) }

    before(:each) { login_as(user, scope: :user) }

    it "returns http success on GET /tasks" do
      get "/tasks"
      expect(response).to have_http_status(:success)
    end
  end
end
