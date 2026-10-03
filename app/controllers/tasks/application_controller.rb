class Tasks::ApplicationController < ApplicationController
  include AccessDeniedHandlers::SensibleResources

  before_action :set_task, only: [ :create, :destroy, :update ]

  def create
    authorize! :read, @task

    TaskApplication.transaction do
      # Clear out any old application
      current_user.task_applications.destroy_by(task: @task)

      # Create new entry
      @application = current_user.task_applications.build(
        task: @task,
        comment: params[:task_application][:comment].presence
      )
      # Keep any old application if the new one is invalid
      raise ActiveRecord::Rollback unless @application.save
    end

    render status: :unprocessable_content unless @application.persisted?
  end

  def update
    authorize! :read, @task

    @application = current_user.task_applications.find_by!(task: @task)
    @updated = @application.update_if_editable(
      comment: params[:task_application][:comment].presence
    )

    render status: :unprocessable_content if @application.errors.any?
  end

  def destroy
    authorize! :read, @task

    @application = current_user.task_applications.find_by!(task: @task)
    @application.destroy_or_withdraw!
  end

  private

  def set_task
    @task = Task.find(params[:task_id])
  end
end
