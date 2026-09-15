class Tasks::ApplicationController < ApplicationController
  include AccessDeniedHandlers::SensibleResources

  before_action :set_task, only: [ :create, :destroy, :update ]

  def create
    authorize! :read, @task

    TaskApplication.transaction do
      # Clear out any old application
      @application = TaskApplication.destroy_by(
        task_id: params[:task_id],
        user_id: current_user.id
      )

      # Create new entry
      @application = TaskApplication.new(
        task_id: params[:task_id],
        user_id: current_user.id,
        comment: params[:task_application][:comment].presence
      )
      @application.save!
    end
  end

  def update
    authorize! :read, @task

    @application = TaskApplication.find_by!(
      task_id: params[:task_id],
      user_id: current_user.id
    )
    @updated = @application.update_if_editable(
      comment: params[:task_application][:comment].presence
    )
  end

  def destroy
    authorize! :read, @task

    @application = TaskApplication.find_by!(
      task_id: @task.id,
      user_id: current_user.id
    )
    @application.destroy_or_withdraw!
  end

  private

  def set_task
    @task = Task.find(params[:task_id])
  end
end
