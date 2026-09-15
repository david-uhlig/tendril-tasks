# frozen_string_literal: true

module Tasks
  module Application
    class StatusController < ApplicationController
      include AccessDeniedHandlers::SensibleResources

      before_action :set_task_application, only: [ :update ]

      def update
        authorize! :coordinate, @task_application.task
        @task_application.with_lock do
          @task_application.update!(status_params) unless @task_application.withdrawn?
        end
      rescue ActiveRecord::RecordInvalid
        head :unprocessable_content
      end

      private

      def status_params
        params.permit(:status)
      end

      def set_task_application
        @task_application = TaskApplication
                              .includes(:task)
                              .find_by!(
                                task_id: params[:task_id],
                                user_id: params[:user_id])
      end
    end
  end
end
