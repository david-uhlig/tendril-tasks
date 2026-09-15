# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Tasks::Application", type: :request do
  let(:user) { create(:user) }
  let(:task) { create(:task, :published, :with_published_project) }

  describe "POST /user/tasks/:task_id/application" do
    it "requires authentication" do
      require_authentication_for { post task_application_path(task) }
    end

    context "when authenticated" do
      before { sign_in user }

      it "saves the application and returns ok" do
        expect {
          post task_application_path(task),
            params: { task_application: { comment: "comment" } },
            as: :turbo_stream
        }.to change(TaskApplication, :count).by(1)
        expect(response).to have_http_status(:ok)
      end

      context "and the the task doesn't exist" do
        it "returns a not found status" do
          post task_application_path(999),
            params: { task_application: { comment: "comment" } },
            as: :turbo_stream
          expect(response).to have_http_status(:not_found)
        end
      end

      context "and the task is not published" do
        it "returns a not found status" do
          task = create(:task, :not_published)
          post task_application_path(task),
            params: { task_application: { comment: "comment" } },
            as: :turbo_stream
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end

  describe "PATCH /user/tasks/:task_id/application" do
    it "requires authentication" do
      require_authentication_for { patch task_application_path(task) }
    end

    context "when authenticated" do
      before { sign_in user }

      context "and the task exists" do
        context "and the application exists" do
          it "updates the application and returns found" do
            application = create(:task_application, task: task, user: user)
            expect {
              patch task_application_path(task),
                    params: { task_application: { comment: "edited comment" } },
                    as: :turbo_stream
            }.to change { application.reload.comment }.to("edited comment")
            expect(response).to have_http_status(:ok)
          end
        end

        context "but the user hasn't previously applied to the task" do
          it "returns a not found status" do
            patch task_application_path(task),
              params: { task_application: { comment: "edited comment" } },
              as: :turbo_stream
            expect(response).to have_http_status(:not_found)
          end
        end

        context "but the task is not published" do
          it "returns a not found status" do
            task = create(:task, :not_published)
            patch task_application_path(task),
              params: { task_application: { comment: "edited comment" } },
              as: :turbo_stream
            expect(response).to have_http_status(:not_found)
          end
        end
      end

      context "and the task doesn't exist" do
        it "returns a not found status" do
          patch task_application_path(999),
            params: { task_application: { comment: "edited comment" } },
            as: :turbo_stream
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end

  describe "DELETE /user/tasks/:task_id/application" do
    it "requires authentication" do
      require_authentication_for { delete task_application_path(task) }
    end

    context "when authenticated" do
      before { sign_in user }

      context "and the task exists" do
        context "and the application exists" do
          it "destroys the application within the grace period and returns ok" do
            application = create(:task_application, task: task, user: user)

            expect {
              delete task_application_path(task), as: :turbo_stream
            }.to change(TaskApplication, :count).by(-1)

            expect(response).to have_http_status(:ok)
            expect { application.reload }.to raise_error(ActiveRecord::RecordNotFound)
          end

          it "withdraws the application after the grace period and returns ok" do
            application = create(:task_application, task: task, user: user)
            application.update_column(:created_at, 31.minutes.ago)

            expect {
              delete task_application_path(task), as: :turbo_stream
            }.not_to change(TaskApplication, :count)

            expect(response).to have_http_status(:ok)
            expect(application.reload).to be_withdrawn
          end
        end

        context "but the user has not previously applied to the task" do
          it "returns a not found status" do
            delete task_application_path(task), as: :turbo_stream

            expect(response).to have_http_status(:not_found)
          end
        end

        context "but the task is not published" do
          it "returns a not found status" do
            task = create(:task, :not_published)
            create(:task_application, task: task, user: user)

            delete task_application_path(task), as: :turbo_stream

            expect(response).to have_http_status(:not_found)
          end
        end
      end

      context "and the task does not exist" do
        it "returns a not found status" do
          delete task_application_path(999), as: :turbo_stream

          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end
end
