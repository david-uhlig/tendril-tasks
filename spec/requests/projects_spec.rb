require 'rails_helper'

RSpec.describe "Projects", type: :request do
  let(:user) { create(:user) }
  let(:editor) { create(:user, :editor) }
  let(:admin) { create(:user, :admin) }

  describe "GET /projects" do
    context "as a visitor" do
      it "redirects to the login page" do
        get projects_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "as a user" do
      it "loads the projects index page" do
        login_as(user)
        get projects_path
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /projects/:id" do
    context "published project with published tasks" do
      let!(:published_project) { create(:project, :published, :with_published_tasks) }

      context "as a visitor" do
        it "redirects to the login page" do
          get project_path(published_project)
          expect(response).to redirect_to(new_user_session_path)
        end
      end

      context "as a user" do
        it "loads the project detail page" do
          login_as(user)
          get project_path(published_project)
          expect(response).to have_http_status(:success)
        end
      end
    end

    context "published project - no published tasks" do
      let!(:published_project) { create(:project, :published) }

      context "as a visitor" do
        it "redirects to the login page" do
          get project_path(published_project)
          expect(response).to redirect_to(new_user_session_path)
        end
      end

      context "as a user" do
        it "responds with a 404" do
          login_as(user)
          get project_path(published_project)
          expect(response).to have_http_status(:not_found)
        end
      end

      context "as a coordinator" do
        let(:coordinator) { create(:user) }
        let(:project) { create(:project, coordinators: [ coordinator ]) }

        it "loads the project detail page" do
          login_as(coordinator)
          get project_path(project)
          expect(response).to have_http_status(:success)
        end
      end

      context "as an editor" do
        it "loads the project detail page" do
          login_as(editor)
          get project_path(published_project)
          expect(response).to have_http_status(:success)
        end
      end
    end

    context "unpublished project" do
      let!(:unpublished_project) { create(:project) }

      context "as a visitor" do
        it "redirects to the login page" do
          get project_path(unpublished_project)
          expect(response).to redirect_to(new_user_session_path)
        end
      end

      context "as a user" do
        it "responds with a 404" do
          login_as(user)
          get project_path(unpublished_project)
          expect(response).to have_http_status(:not_found)
        end
      end

      context "as a coordinator" do
        let(:coordinator) { create(:user) }
        let(:project) { create(:project, coordinators: [ coordinator ]) }

        it "loads the project detail page" do
          login_as(coordinator)
          get project_path(project)
          expect(response).to have_http_status(:success)
        end
      end

      context "as an editor" do
        it "loads the project detail page" do
          login_as(editor)
          get project_path(unpublished_project)
          expect(response).to have_http_status(:success)
        end
      end
    end
  end

  describe "GET /projects/new" do
    context "as a visitor" do
      it "redirects to the login page" do
        get new_project_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "as a user" do
      it "redirects to the projects index" do
        login_as(user)
        get new_project_path
        expect(response).to redirect_to(projects_path)
      end
    end

    context "as an editor" do
      it "loads the new project page" do
        login_as(editor)
        get new_project_path
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /projects/:id/edit" do
    let(:project) { create(:project) }

    context "as a visitor" do
      it "redirects to the login page" do
        get edit_project_path(project)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "as a user" do
      it "redirects to the projects index" do
        login_as(user)
        get edit_project_path(project)
        expect(response).to have_http_status(:not_found)
      end
    end

    context "as a coordinator" do
      let(:coordinator) { create(:user) }
      let(:project) { create(:project, coordinators: [ coordinator ]) }

      it "loads the edit project page" do
        login_as(coordinator)
        get edit_project_path(project)
        expect(response).to have_http_status(:success)
      end
    end

    context "as an editor" do
      it "loads the edit project page" do
        login_as(editor)
        get edit_project_path(project)
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "POST /projects" do
    context "as a visitor" do
      it "redirects to the login page" do
        post projects_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "as a user" do
      it "redirects to the projects index" do
        login_as(user)
        post projects_path
        expect(response).to redirect_to(projects_path)
      end
    end

    context "as an editor" do
      it "creates a new project" do
        login_as(editor)
        post projects_path, params: { project_form: attributes_for(:project) }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "PATCH /projects/:id" do
    let(:project) { create(:project) }

    context "as a visitor" do
      it "redirects to the login page" do
        patch project_path(project)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "as a user" do
      it "responds with not found" do
        login_as(user)
        patch project_path(project)
        expect(response).to have_http_status(:not_found)
      end
    end

    context "as a coordinator" do
      let(:coordinator) { create(:user) }
      let(:project) { create(:project, coordinators: [ coordinator ]) }

      it "updates the project" do
        login_as(coordinator)
        patch project_path(project), params: { project_form: attributes_for(:project) }
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(project_path(project))
      end
    end

    context "as an editor" do
      it "updates the project" do
        login_as(editor)
        patch project_path(project), params: { project_form: attributes_for(:project) }
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(project_path(project))
      end
    end
  end

  describe "DELETE /projects/:id" do
    let(:project) { create(:project) }

    context "as a visitor" do
      it "redirects to the login page" do
        delete project_path(project)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "as a user" do
      it "responds with not found" do
        login_as(user)
        delete project_path(project)
        expect(response).to have_http_status(:not_found)
      end
    end

    context "as a coordinator" do
      let(:coordinator) { create(:user) }
      let(:project) { create(:project, coordinators: [ coordinator ]) }

      it "deletes the project" do
        login_as(coordinator)
        delete project_path(project)
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(projects_path)
      end
    end

    context "as an editor" do
      it "deletes the project" do
        login_as(editor)
        delete project_path(project)
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(projects_path)
      end
    end
  end
end
