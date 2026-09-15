# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Tasks::Application::StatusController", type: :request do
  let(:applicant) { create(:user) }
  let(:coordinator) { create(:user) }
  let(:task) { create(:task, :published, :with_published_project) }

  def status_path(task, user)
    task_application_status_path(task_id: task, user_id: user)
  end

  describe "PATCH /tasks/:task_id/applications/:user_id/status" do
    it "requires authentication" do
      require_authentication_for do
        patch status_path(task, applicant), params: { status: "accepted" }
      end
    end

    context "when authenticated" do
      before do
        sign_in coordinator
        task.coordinators << coordinator
      end

      context "when the application exists" do
        let!(:application) do
          create(:task_application, task: task, user: applicant, status: :received)
        end

        it "updates the application status" do
          expect {
            patch status_path(task, applicant),
                  params: { status: "accepted" },
                  as: :turbo_stream
          }.to change { application.reload.status }.from("received").to("accepted")

          expect(response).to have_http_status(:ok)
        end

        it "does not update a withdrawn application" do
          application.update!(status: :withdrawn)

          expect {
            patch status_path(task, applicant),
                  params: { status: "accepted" },
                  as: :turbo_stream
          }.not_to change { application.reload.status }

          expect(response).to have_http_status(:ok)
        end
      end

      context "when the application does not exist" do
        it "returns not found" do
          patch status_path(task, applicant),
                params: { status: "accepted" },
                as: :turbo_stream

          expect(response).to have_http_status(:not_found)
        end
      end

      context "when the task does not exist" do
        it "returns not found" do
          patch status_path(999, applicant),
                params: { status: "accepted" },
                as: :turbo_stream

          expect(response).to have_http_status(:not_found)
        end
      end

      context "when the user does not belong to the application" do
        it "returns not found" do
          application = create(:task_application, task: task, user: applicant)

          patch status_path(task, create(:user)),
                params: { status: "accepted" },
                as: :turbo_stream

          expect(response).to have_http_status(:not_found)
          expect(application.reload.status).to eq("received")
        end
      end

      context "when updating the application fails validation" do
        let!(:application) do
          create(:task_application, task: task, user: applicant, status: :received)
        end

        it "returns unprocessable entity" do
          validation_error = ActiveRecord::RecordInvalid.new(application)

          allow_any_instance_of(TaskApplication)
            .to receive(:update!)
                  .and_raise(validation_error)

          patch status_path(task, applicant),
                params: { status: "accepted" },
                as: :turbo_stream

          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    context "when the user is not authorized to coordinate the task" do
      before { sign_in applicant }

      it "returns not found" do
        create(:task_application, task: task, user: applicant)

        patch status_path(task, applicant),
              params: { status: "accepted" },
              as: :turbo_stream

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
