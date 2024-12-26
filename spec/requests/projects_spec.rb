require 'rails_helper'

RSpec.describe "Projects", type: :request do
  context "when logged in as user" do
    let(:user) { create(:user) }
    let(:published_project) { create(:project, :published, :with_published_tasks) }

    before(:each) {
      login_as(user, scope: :user)
      published_project
    }

    it "can access the projects index page" do
      get projects_path
      expect(response).to have_http_status(:success)
    end

    it "can access published project with published tasks" do
      get project_path(published_project)
      expect(response).to have_http_status(:success)
    end
  end

  context "when logged in as an editor" do
    let(:editor) { create(:user, :editor) }
    before(:each) { login_as(editor, scope: :user) }

    it "can access new project page" do
      get new_project_path
      expect(response).to have_http_status(:success)
    end
  end

  context "when assigned as a coordinator" do
    let(:coordinator) { create(:user) }
    let(:project) { create(:project, coordinators: [ coordinator ]) }
    before(:each) { login_as(coordinator, scope: :user) }

    it "can access the projects detail page" do
      get project_path(project)
      expect(response).to have_http_status(:success)
    end

    it "can access the projects edit page" do
      get edit_project_path(project)
      expect(response).to have_http_status(:success)
    end
  end
end
