require "rails_helper"

RSpec.describe "Tasks::Projects", type: :request do
  let(:user) { create(:user) }
  let(:editor) { create(:user, :editor) }
  let(:valid_params) do
    { project_form: { title: "New initiative", description: "Some description", publish: "1" } }
  end

  describe "POST /tasks/projects" do
    it "requires authentication" do
      require_authentication_for {
        post tasks_projects_path, params: valid_params, as: :turbo_stream
      }
    end

    it "is forbidden for users who can't create initiatives" do
      login_as(user)

      expect {
        post tasks_projects_path, params: valid_params, as: :turbo_stream
      }.not_to change(Project, :count)
      expect(response).to have_http_status(:forbidden)
    end

    context "as an editor" do
      before { login_as(editor) }

      it "creates the initiative with the current user as its only coordinator", :aggregate_failures do
        other = create(:user)

        expect {
          post tasks_projects_path,
               params: valid_params.deep_merge(project_form: { coordinator_ids: [ other.id ] }),
               as: :turbo_stream
        }.to change(Project, :count).by(1)

        project = Project.last
        expect(response).to have_http_status(:success)
        expect(project.title).to eq("New initiative")
        expect(project).to be_published
        expect(project.coordinators).to contain_exactly(editor)
      end

      it "selects the new initiative in the task form", :aggregate_failures do
        post tasks_projects_path, params: valid_params, as: :turbo_stream

        project = Project.last
        expect(response.body).to include('target="task_form_project_id"')
        expect(response.body).to include(%(<option selected="selected" value="#{project.id}">New initiative</option>))
      end

      it "creates a draft when not published" do
        post tasks_projects_path,
             params: valid_params.deep_merge(project_form: { publish: "0" }),
             as: :turbo_stream

        expect(Project.last).not_to be_published
      end

      it "shows the errors in the modal when invalid", :aggregate_failures do
        expect {
          post tasks_projects_path,
               params: valid_params.deep_merge(project_form: { title: "" }),
               as: :turbo_stream
        }.not_to change(Project, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include('target="new-project-form"')
        expect(response.body).not_to include('target="task_form_project_id"')
      end
    end
  end
end
