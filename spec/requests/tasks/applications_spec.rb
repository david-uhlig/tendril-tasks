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

      it "celebrates the application with fireworks" do
        post task_application_path(task),
          params: { task_application: { comment: "comment" } },
          as: :turbo_stream
        expect(response.body).to include('data-controller="fireworks"')
      end

      it "limits the comment length in the form" do
        post task_application_path(task),
          params: { task_application: { comment: "comment" } },
          as: :turbo_stream
        expect(response.body).to include(%(maxlength="#{TaskApplication::COMMENT_MAX_LENGTH}"))
      end

      context "and the comment is too long" do
        let(:comment) { "a" * (TaskApplication::COMMENT_MAX_LENGTH + 1) }

        it "doesn't save the application and shows the error" do
          expect {
            post task_application_path(task),
              params: { task_application: { comment: comment } },
              as: :turbo_stream
          }.not_to change(TaskApplication, :count)
          expect(response).to have_http_status(:unprocessable_content)
          expect(response.body).to include(
            I18n.t("activerecord.errors.models.task_application.attributes.comment.too_long",
                   count: TaskApplication::COMMENT_MAX_LENGTH)
          )
          expect(response.body).to include(comment)
          expect(response.body).not_to include('data-controller="fireworks"')
        end

        it "keeps a previously withdrawn application" do
          application = create(:task_application, :grace_period_expired, task: task, user: user)
          application.destroy_or_withdraw!

          post task_application_path(task),
            params: { task_application: { comment: comment } },
            as: :turbo_stream
          expect(application.reload).to be_withdrawn
        end
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

          it "doesn't celebrate the application with fireworks" do
            create(:task_application, task: task, user: user)
            patch task_application_path(task),
                  params: { task_application: { comment: "edited comment" } },
                  as: :turbo_stream
            expect(response.body).not_to include('data-controller="fireworks"')
          end

          context "and the comment is too long" do
            let(:comment) { "a" * (TaskApplication::COMMENT_MAX_LENGTH + 1) }

            it "doesn't update the application and shows the error" do
              application = create(:task_application, task: task, user: user)
              expect {
                patch task_application_path(task),
                      params: { task_application: { comment: comment } },
                      as: :turbo_stream
              }.not_to change { application.reload.comment }
              expect(response).to have_http_status(:unprocessable_content)
              expect(response.body).to include(
                I18n.t("activerecord.errors.models.task_application.attributes.comment.too_long",
                       count: TaskApplication::COMMENT_MAX_LENGTH)
              )
              expect(response.body).not_to include(%(target="task-application-#{user.id}"))
            end
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
            application = create(:task_application, task: task, user: user, comment: "Count me in!")

            expect {
              delete task_application_path(task), as: :turbo_stream
            }.to change(TaskApplication, :count).by(-1)

            expect(response).to have_http_status(:ok)
            expect(Nokogiri::HTML(response.body).at_css("turbo-stream[target=task-application]").to_html).not_to include("Count me in!")
            expect { application.reload }.to raise_error(ActiveRecord::RecordNotFound)
          end

          it "withdraws the application after the grace period and returns ok" do
            application = create(:task_application, task: task, user: user, comment: "Count me in!")
            application.update_column(:created_at, 31.minutes.ago)

            expect {
              delete task_application_path(task), as: :turbo_stream
            }.not_to change(TaskApplication, :count)

            expect(response).to have_http_status(:ok)
            expect(Nokogiri::HTML(response.body).at_css("turbo-stream[target=task-application]").to_html).not_to include("Count me in!")
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
