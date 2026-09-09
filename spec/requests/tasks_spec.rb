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

      it "can view the task list" do
        get tasks_path
        expect(response).to have_http_status(:success)
      end

      it "displays published tasks" do
        task = create(:task, :published, :with_published_project)
        get tasks_path
        expect(response.body).to include(task.title)
      end

      it "does not display unpublished tasks" do
        task = create(:task, :not_published)
        get tasks_path
        expect(response.body).not_to include(task.title)
      end

      it "does not display tasks from unpublished projects" do
        task = create(:task, :published, :with_unpublished_project)
        get tasks_path
        expect(response.body).not_to include(task.title)
      end

      it "shows projects with published tasks in the project filter" do
        create(
          :project,
          :published,
          :with_published_tasks,
          title: "Published Project with published tasks"
        )

        get tasks_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include("Published Project with published tasks")
      end

      it "does not show projects with unpublished tasks" do
        create(
          :project,
          :published,
          :with_unpublished_tasks,
          title: "Published Project with unpublished tasks"
        )

        get tasks_path

        expect(response.body).not_to include("Published Project with unpublished tasks")
      end

      it "does not show unpublished projects" do
        create(:project, :not_published, title: "Unpublished Project")

        get tasks_path

        expect(response.body).not_to include("Unpublished Project")
      end

      it "does not show the new task link" do
        get tasks_path

        expect(response.body).not_to include("Aufgabe anlegen")
      end
    end

    context "when authorized as an editor" do
      before(:each) { login_as(editor) }

      it "shows projects with published tasks in the project filter" do
        create(
          :project,
          :published,
          :with_published_tasks,
          title: "Published Project with published tasks"
        )

        get tasks_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include("Published Project with published tasks")
      end

      it "does not show projects with unpublished tasks" do
        create(
          :project,
          :published,
          :with_unpublished_tasks,
          title: "Published Project with unpublished tasks"
        )

        get tasks_path

        expect(response.body).not_to include("Published Project with unpublished tasks")
      end

      it "does not show unpublished projects" do
        create(:project, :not_published, title: "Unpublished Project")

        get tasks_path

        expect(response.body).not_to include("Unpublished Project")
      end

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
      post tasks_path, params: { task_form: attributes_for(:task) }
      expect(response).to have_http_status(:unprocessable_content)
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

      patch task_path(task), params: { task_form: attributes_for(:task) }

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(task_path(task))
    end

    it "editors can update the task" do
      login_as(editor)
      task = create(:task)

      patch task_path(task), params: { task_form: attributes_for(:task) }
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(task_path(task))
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
    end

    it "coordinators can delete the task" do
      login_as(user)
      task = create(:task, coordinators: [ user ])
      delete task_path(task)
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(tasks_path)
    end

    it "editors can delete the task" do
      login_as(editor)
      task = create(:task)
      delete task_path(task)
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(tasks_path)
    end
  end
end
