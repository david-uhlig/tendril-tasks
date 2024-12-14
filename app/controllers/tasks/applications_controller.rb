class Tasks::ApplicationsController < ApplicationController
  before_action :set_task, only: [ :create, :destroy ]

  def create
    authorize! :read, @task
    # Clear out any old application
    @application = TaskApplication.destroy_by(
      task_id: params[:task_id],
      user_id: current_user.id
    )
    # Create new entry
    @application = TaskApplication.new(
      task_id: params[:task_id],
      user_id: current_user.id
    )
    @application.save!
  end

  def destroy
    authorize! :read, @task
    @application = TaskApplication.find_by(
      task_id: @task.id,
      user_id: current_user.id
    )
    @application.withdraw
    @application.save!
  end

  private

  def set_task
    @task = Task.find(params[:task_id])
  end
end
