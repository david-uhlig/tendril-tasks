require 'rails_helper'

RSpec.describe "Projects", type: :request do
  context "when logged in as user" do
    let(:user) { create(:user) }
    before(:each) { login_as(user, scope: :user) }

    it "can access the projects index page" do
      get projects_path
      expect(response).to have_http_status(:success)
    end

    it "can access published project with published tasks" do
      project = create(:project, :published, :with_published_tasks)
      get project_path(project)
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
end
