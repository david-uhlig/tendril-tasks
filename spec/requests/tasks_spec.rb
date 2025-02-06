require 'rails_helper'

RSpec.describe "Tasks", type: :request do
  let(:user) { create(:user) }
  let(:editor) { create(:user, :editor) }
  let(:admin) { create(:user, :admin) }

  describe "GET /tasks" do
    context "as a visitor" do
      it "redirects to the login page" do
        get tasks_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "as a user" do
      it "loads the tasks index page" do
        login_as(user)
        get tasks_path
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /tasks/:id" do
    context "published task with published project" do
      let!(:published_task) { create(:task, :published, :with_published_project) }

      context "as a visitor" do
        it "redirects to the login page" do
          get task_path(published_task)
          expect(response).to redirect_to(new_user_session_path)
        end
      end

      context "as a user" do
        it "loads the task detail page" do
          login_as(user)
          get task_path(published_task)
          expect(response).to have_http_status(:success)
        end
      end
    end

    context "published task - unpublished project" do
      let!(:published_task) { create(:task, :published) }

      context "as a visitor" do
        it "redirects to the login page" do
          get task_path(published_task)
          expect(response).to redirect_to(new_user_session_path)
        end
      end

      context "as a user" do
        it "responds with a 404" do
          login_as(user)
          get task_path(published_task)
          expect(response).to have_http_status(:not_found)
        end
      end

      context "as a coordinator" do
        it "loads the task detail page" do
          login_as(user)
          task = create(:task, coordinators: [ user ])

          get task_path(task)
          expect(response).to have_http_status(:success)
        end
      end

      context "as an editor" do
        it "loads the task detail page" do
          login_as(editor)
          task = create(:task)

          get task_path(task)
          expect(response).to have_http_status(:success)
        end
      end
    end

    context "unpublished task" do
      let!(:unpublished_task) { create(:task) }

      context "as a visitor" do
        it "redirects to the login page" do
          get task_path(unpublished_task)
          expect(response).to redirect_to(new_user_session_path)
        end
      end

      context "as a user" do
        it "responds with a 404" do
          login_as(user)
          get task_path(unpublished_task)
          expect(response).to have_http_status(:not_found)
        end
      end

      context "as a coordinator" do
        it "responds with a 404" do
          login_as(user)
          task = create(:task, coordinators: [ user ])

          get task_path(task)
          expect(response).to have_http_status(:success)
        end
      end

      context "as an editor" do
        it "loads the task detail page" do
          login_as(editor)
          get task_path(unpublished_task)
          expect(response).to have_http_status(:success)
        end
      end
    end
  end

  describe "GET /tasks/:id/edit" do
    context "as a visitor" do
      it "redirects to the login page" do
        task = create(:task)
        get edit_task_path(task)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "as a user" do
      it "responds with not found " do
        task = create(:task)
        login_as(user)
        get edit_task_path(task)
        expect(response).to have_http_status(:not_found)
      end
    end

    context "as a coordinator" do
      it "loads the task edit page" do
        task = create(:task, coordinators: [ user ])
        login_as(user)
        get edit_task_path(task)
        expect(response).to have_http_status(:success)
      end
    end

    context "as an editor" do
      it "loads the task edit page" do
        task = create(:task)
        login_as(editor)
        get edit_task_path(task)
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /tasks/new" do
    context "as a visitor" do
      it "redirects to the login page" do
        get new_task_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "as a user" do
      it "loads the new task page" do
        login_as(user)
        get new_task_path
        expect(response).to redirect_to(tasks_path)
      end
    end
  end

  describe "GET /tasks/new/from-preset/:project_id/:coordinator_ids" do
    context "as a visitor" do
      it "redirects to the login page" do
        project = create(:project)
        coordinator = create(:user)

        get new_task_from_preset_path(project_id: project.id, coordinator_ids: [ coordinator.id ])
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "as a user" do
      it "loads the new task page" do
        login_as(user)
        project = create(:project)
        coordinator = create(:user)

        get new_task_from_preset_path(project_id: project.id, coordinator_ids: [ coordinator.id ])
        expect(response).to redirect_to(tasks_path)
      end
    end

    context "as an editor" do
      it "loads the new task page" do
        login_as(editor)
        project = create(:project)
        coordinator = create(:user)

        get new_task_from_preset_path(project_id: project.id, coordinator_ids: [ coordinator.id ])
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "POST /tasks" do
    context "as a visitor" do
      it "redirects to the login page" do
        post tasks_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "as a user" do
      it "redirects to the tasks index page" do
        login_as(user)
        post tasks_path
        expect(response).to redirect_to(tasks_path)
      end
    end

    context "as an editor" do
      it "loads the new task page" do
        login_as(editor)
        post tasks_path, params: { task_form: attributes_for(:task) }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH /tasks/:id" do
    context "as a visitor" do
      it "redirects to the login page" do
        task = create(:task)
        patch task_path(task)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "as a user" do
      it "responds with not found " do
        task = create(:task)
        login_as(user)
        patch task_path(task)
        expect(response).to have_http_status(:not_found)
      end
    end

    context "as a coordinator" do
      it "loads the task edit page" do
        task = create(:task, coordinators: [ user ])
        login_as(user)
        patch task_path(task), params: { task_form: attributes_for(:task) }
        expect(response).to have_http_status(:found)
      end
    end

    context "as an editor" do
      it "loads the task edit page" do
        task = create(:task)
        login_as(editor)
        patch task_path(task), params: { task_form: attributes_for(:task) }
        expect(response).to have_http_status(:found)
      end
    end
  end

  describe "DELETE /tasks/:id" do
    context "as a visitor" do
      it "redirects to the login page" do
        task = create(:task)
        delete task_path(task)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "as a user" do
      it "responds with not found " do
        task = create(:task)
        login_as(user)
        delete task_path(task)
        expect(response).to have_http_status(:not_found)
      end
    end

    context "as a coordinator" do
      it "loads the task edit page" do
        task = create(:task, coordinators: [ user ])
        login_as(user)
        delete task_path(task)
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(tasks_path)
      end
    end

    context "as an editor" do
      it "loads the task edit page" do
        task = create(:task)
        login_as(editor)
        delete task_path(task)
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(tasks_path)
      end
    end
  end
end
