require 'rails_helper'

RSpec.describe "Tasks", type: :request do
  context "when logged out" do
    it "raises a CanCan::AccessDenied exception on GET /tasks" do
      expect {
        get tasks_path
      }.to raise_error(CanCan::AccessDenied)
    end

    it "raises a CanCan::AccessDenied exception on POST /tasks" do
      expect {
        post tasks_path
      }.to raise_error(CanCan::AccessDenied)
    end

    it "raises a CanCan::AccessDenied exception on GET /tasks/new" do
      expect {
        get new_task_path
      }.to raise_error(CanCan::AccessDenied)
    end

    it "raises a CanCan::AccessDenied exception on GET /tasks/:id/edit" do
      task = create(:task)

      expect {
        get edit_task_path(task)
      }.to raise_error(CanCan::AccessDenied)
    end

    it "raises a CanCan::AccessDenied exception on GET /tasks/:id" do
      task = create(:task)

      expect {
        get task_path(task)
      }.to raise_error(CanCan::AccessDenied)
    end

    it "raises a CanCan::AccessDenied exception on PATCH /tasks/:id" do
      task = create(:task)

      expect {
        patch task_path(task)
      }.to raise_error(CanCan::AccessDenied)
    end

    it "raises a CanCan::AccessDenied exception on PUT /tasks/:id" do
      task = create(:task)

      expect {
        put task_path(task)
      }.to raise_error(CanCan::AccessDenied)
    end

    it "raises a CanCan::AccessDenied exception on DELETE /tasks/:id" do
      task = create(:task)

      expect {
        delete task_path(task)
      }.to raise_error(CanCan::AccessDenied)
    end

    it "raises a CanCan::AccessDenied exception on GET /tasks/new/from-preset/:project_id/:coordinator_ids" do
      project = create(:project)
      coordinator = create(:user)

      expect {
        get new_task_with_preset_path(project_id: project.id, coordinator_ids: [ coordinator.id ])
      }.to raise_error(CanCan::AccessDenied)
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
