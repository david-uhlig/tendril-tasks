# frozen_string_literal: true

module Tasks
  module Applications
    class StatusesController < ApplicationController
      before_action :set_task_application, only: [ :update ]

      def update
        authorize! :coordinate, @task_application.task
        unless @task_application.withdrawn?
          @task_application.update!(status_params)
        end
      end

      private

      def status_params
        params.permit(:status)
      end

      def set_task_application
        @task_application = TaskApplication
                              .includes(:task)
                              .find_by(
                                task_id: params[:task_id],
                                user_id: params[:user_id])
      end
    end
  end
end
