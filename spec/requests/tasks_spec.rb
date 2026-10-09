require "rails_helper"

RSpec.describe "Tasks", type: :request do
  let(:user) { create(:user) }
  let(:editor) { create(:user, :editor) }

  let(:published_task) { create(:task, :published, :with_published_project) }

  describe "GET /tasks" do
    it "requires authentication" do
      require_authentication_for { get tasks_path }
    end

    context "when authenticated" do
      before(:each) { login_as(user) }

      it "lists and links published tasks from published projects only", :aggregate_failures do
        task = create(:task, :published, :with_published_project, title: "Published task")
        create(:task, :not_published, :with_published_project, title: "Unpublished task")
        create(:task, :published, :with_unpublished_project, title: "Task from an unpublished project")

        get tasks_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include("Published task", %(href="#{task_path(task)}"))
        expect(response.body).not_to include("Unpublished task")
        expect(response.body).not_to include("Task from an unpublished project")
      end

      it "offers only published projects with published tasks in the project filter", :aggregate_failures do
        create(:project, :published, :with_published_tasks, title: "Project with published tasks")
        create(:project, :published, :with_unpublished_tasks, title: "Project with unpublished tasks")
        create(:project, :not_published, title: "Unpublished project")

        get tasks_path

        expect(response.body).to include("Project with published tasks")
        expect(response.body).not_to include("Project with unpublished tasks")
        expect(response.body).not_to include("Unpublished project")
      end

      it "does not show the new task link" do
        get tasks_path

        expect(response.body).not_to include("Aufgabe anlegen")
      end
    end

    context "when authorized as an editor" do
      before(:each) { login_as(editor) }

      it "shows the new task link" do
        get tasks_path

        expect(response.body).to include("Aufgabe anlegen")
      end
    end
  end

  describe "POST /tasks" do
    it "requires authentication" do
      require_authentication_for { post tasks_path }
    end

    it "unauthorized users are redirected to the task list" do
      login_as(user)
      post tasks_path
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(tasks_path)
    end

    # Requires editor role or above.
    it "authorized users can create tasks" do
      login_as(editor)
      project = create(:project)

      expect {
        post tasks_path, params: {
          task_form: { project_id: project.id, title: "New task", description: "A new task description" },
          assigned_coordinator_ids: [ editor.id ]
        }
      }.to change(Task, :count).by(1)

      task = Task.last
      expect(response).to redirect_to(task_path(task))
      expect(task).to have_attributes(title: "New task", project: project, coordinators: [ editor ])
    end

    it "rejects invalid tasks" do
      login_as(editor)

      expect {
        post tasks_path, params: { task_form: attributes_for(:task) }
      }.not_to change(Task, :count)
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "responds with bad request when the task form is missing" do
      login_as(editor)
      post tasks_path

      expect(response).to have_http_status(:bad_request)
    end

    context "when saving and creating a new task" do
      let(:project) { create(:project, coordinators: [ create(:user, name: "Project Coordinator") ]) }
      let(:task_coordinator) { create(:user, name: "Task Coordinator") }
      let(:params) do
        {
          task_form: {
            project_id: project.id,
            title: "Task title",
            description: "Some task description that is long enough!",
            submit_type: "save_and_new"
          },
          assigned_coordinator_ids: [ editor.id, task_coordinator.id ]
        }
      end

      before { login_as(editor) }

      it "redirects to a new task preset with the project and the task's coordinators" do
        post tasks_path, params: params

        expect(response).to redirect_to(
          new_task_from_preset_path(
            project_id: project.id,
            coordinator_ids: Task.last.coordinator_ids.join("-")
          )
        )
        expect(Task.last.coordinator_ids).to contain_exactly(editor.id, task_coordinator.id)
      end

      it "renders the preset form with the task's coordinators" do
        post tasks_path, params: params
        follow_redirect!

        expect(response).to have_http_status(:success)
        expect(response.body).to include("Task Coordinator")
      end
    end
  end

  describe "GET /tasks/new" do
    it "requires authentication" do
      require_authentication_for { get new_task_path }
    end

    it "unauthorized users cannot create new tasks" do
      login_as(user)
      get new_task_path
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(tasks_path)
    end

    it "editors can create new tasks" do
      login_as(editor)
      get new_task_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /tasks/:id/edit" do
    it "requires authentication" do
      require_authentication_for { get edit_task_path(published_task) }
    end

    it "unauthorized users cannot edit the task" do
      login_as(user)
      get edit_task_path(published_task)
      expect(response).to have_http_status(:not_found)
    end

    it "coordinators can edit the task" do
      login_as(user)
      published_task = create(:task, :published, :with_published_project, coordinators: [ user ])

      get edit_task_path(published_task)

      expect(response).to have_http_status(:success)
    end

    it "editors can edit the task" do
      login_as(editor)
      published_task = create(:task, :published, :with_published_project)
      get edit_task_path(published_task)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /tasks/:id" do
    it "requires authentication" do
      require_authentication_for { get task_path(published_task) }
    end

    context "unauthorized users" do
      before(:each) { login_as(user) }

      it "can view published task details" do
        get task_path(published_task)
        expect(response).to have_http_status(:success)
        expect(response.body).to include(published_task.title)
      end

      it "cannot view unpublished task details" do
        unpublished_task = create(:task, :not_published)
        get task_path(unpublished_task)
        expect(response).to have_http_status(:not_found)
      end

      it "cannot view task details from unpublished projects" do
        unpublished_task = create(:task, :published, :with_unpublished_project)
        get task_path(unpublished_task)
        expect(response).to have_http_status(:not_found)
      end
    end

    context "coordinators" do
      before(:each) { login_as(user) }

      it "can view unpublished task details" do
        unpublished_task = create(:task, :not_published, coordinators: [ user ])
        get task_path(unpublished_task)
        expect(response).to have_http_status(:success)
        expect(response.body).to include(unpublished_task.title)
      end

      it "can view task details from unpublished projects" do
        unpublished_task = create(:task, :published, :with_unpublished_project, coordinators: [ user ])
        get task_path(unpublished_task)
        expect(response).to have_http_status(:success)
        expect(response.body).to include(unpublished_task.title)
      end
    end

    context "editors" do
      before(:each) { login_as(editor) }

      it "can view unpublished task details" do
        unpublished_task = create(:task, :not_published)
        get task_path(unpublished_task)
        expect(response).to have_http_status(:success)
        expect(response.body).to include(unpublished_task.title)
      end

      it "can view task details from unpublished projects" do
        unpublished_task = create(:task, :published, :with_unpublished_project)
        get task_path(unpublished_task)
        expect(response).to have_http_status(:success)
        expect(response.body).to include(unpublished_task.title)
      end
    end
  end

  describe "PATCH /tasks/:id" do
    it "requires authentication" do
      require_authentication_for { patch task_path(published_task) }
    end

    it "unauthorized users cannot update the task" do
      login_as(user)
      patch task_path(published_task)
      expect(response).to have_http_status(:not_found)
    end

    it "coordinators can update the task" do
      login_as(user)
      task = create(:task, coordinators: [ user ])

      patch task_path(task), params: { task_form: { title: "Updated title" } }

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(task_path(task))
      expect(task.reload.title).to eq("Updated title")
    end

    it "editors can update the task" do
      login_as(editor)
      task = create(:task)

      patch task_path(task), params: { task_form: { title: "Updated title" } }
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(task_path(task))
      expect(task.reload.title).to eq("Updated title")
    end

    it "shows a notice when the task changed" do
      login_as(editor)
      task = create(:task)

      patch task_path(task), params: { task_form: { title: "A changed title" } }

      expect(flash[:notice]).to be_present
    end

    it "shows no notice when the task didn't change" do
      login_as(editor)
      task = create(:task)

      patch task_path(task), params: { task_form: { title: task.title } }

      expect(flash[:notice]).to be_blank
    end

    it "responds with bad request when the task form is missing" do
      login_as(editor)
      task = create(:task)

      patch task_path(task)

      expect(response).to have_http_status(:bad_request)
    end
  end

  describe "DELETE /tasks/:id" do
    it "requires authentication" do
      require_authentication_for { delete task_path(published_task) }
    end

    it "unauthorized users cannot delete the task" do
      login_as(user)
      delete task_path(published_task)
      expect(response).to have_http_status(:not_found)
      expect(Task.exists?(published_task.id)).to be(true)
    end

    it "coordinators can delete the task" do
      login_as(user)
      task = create(:task, coordinators: [ user ])
      delete task_path(task)
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(tasks_path)
      expect(Task.exists?(task.id)).to be(false)
    end

    it "editors can delete the task" do
      login_as(editor)
      task = create(:task)
      delete task_path(task)
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(tasks_path)
      expect(Task.exists?(task.id)).to be(false)
    end
  end
end
