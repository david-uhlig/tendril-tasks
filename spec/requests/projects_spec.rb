require "rails_helper"

RSpec.describe "Projects", type: :request do
  let(:user) { create(:user) }
  let(:editor) { create(:user, :editor) }
  let(:admin) { create(:user, :admin) }

  describe "GET /projects" do
    context "requires authentication" do
      it "redirects unauthenticated users to the login page" do
        require_authentication_for { get projects_path }
      end
    end

    context "authenticated users" do
      before(:each) { login_as(user) }

      it "shows published projects with published tasks only", :aggregate_failures do
        create(:project, :published, :with_published_tasks, title: "Project with published tasks")
        create(:project, :published, :with_unpublished_tasks, title: "Project with unpublished tasks")
        create(:project, :not_published, title: "Unpublished project")

        get projects_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include("Project with published tasks")
        expect(response.body).not_to include("Project with unpublished tasks")
        expect(response.body).not_to include("Unpublished project")
      end

      it "does not show the new project link to regular users" do
        get projects_path

        expect(response.body).not_to include("Thema anlegen")
      end
    end

    context "authorized users" do
      before do
        login_as(editor)
      end

      it "shows the new project link" do
        get projects_path

        expect(response.body).to include("Thema anlegen")
      end
    end
  end

  describe "GET /projects/:id" do
    it "redirects visitors to the login page" do
      get project_path(create(:project, :published, :with_published_tasks))
      expect(response).to redirect_to(new_user_session_path)
    end

    context "published project with published tasks" do
      let!(:published_project) { create(:project, :published, :with_published_tasks) }

      context "as a user" do
        it "loads the project detail page" do
          login_as(user)
          get project_path(published_project)
          expect(response).to have_http_status(:success)
        end

        it "escapes the project title in the task section headline" do
          published_project.update!(title: "<script>alert(1)</script>")
          login_as(user)
          get project_path(published_project)
          expect(response.body).not_to include("<script>alert(1)</script>")
          expect(response.body).to include("&lt;script&gt;alert(1)&lt;/script&gt;")
        end
      end
    end

    context "published project - no published tasks" do
      let!(:published_project) { create(:project, :published) }

      context "as a user" do
        it "responds with a 404" do
          login_as(user)
          get project_path(published_project)
          expect(response).to have_http_status(:not_found)
        end
      end

      context "as a coordinator" do
        let(:coordinator) { create(:user) }
        let(:project) { create(:project, :published, coordinators: [ coordinator ]) }

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
      it "responds with not found" do
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

        expect {
          post projects_path, params: {
            project_form: { title: "New project", description: "A new project description" },
            assigned_coordinator_ids: [ editor.id ]
          }
        }.to change(Project, :count).by(1)

        project = Project.last
        expect(response).to redirect_to(project_path(project))
        expect(project).to have_attributes(title: "New project", coordinators: [ editor ])
      end

      it "rejects invalid projects" do
        login_as(editor)

        expect {
          post projects_path, params: { project_form: attributes_for(:project) }
        }.not_to change(Project, :count)
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "responds with bad request when the project form is missing" do
        login_as(editor)
        post projects_path

        expect(response).to have_http_status(:bad_request)
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
        patch project_path(project), params: { project_form: { title: "Updated title" } }
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(project_path(project))
        expect(project.reload.title).to eq("Updated title")
      end
    end

    context "as an editor" do
      it "updates the project" do
        login_as(editor)
        patch project_path(project), params: { project_form: { title: "Updated title" } }
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(project_path(project))
        expect(project.reload.title).to eq("Updated title")
      end

      it "shows a notice when the project changed" do
        login_as(editor)
        patch project_path(project), params: { project_form: { title: "A changed title" } }

        expect(flash[:notice]).to be_present
      end

      it "shows no notice when the project didn't change" do
        login_as(editor)
        patch project_path(project), params: { project_form: { title: project.title } }

        expect(flash[:notice]).to be_blank
      end

      it "responds with bad request when the project form is missing" do
        login_as(editor)
        patch project_path(project)

        expect(response).to have_http_status(:bad_request)
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
        expect(Project.exists?(project.id)).to be(true)
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
        expect(Project.exists?(project.id)).to be(false)
      end
    end

    context "as an editor" do
      it "deletes the project" do
        login_as(editor)
        delete project_path(project)
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(projects_path)
        expect(Project.exists?(project.id)).to be(false)
      end
    end
  end
end
