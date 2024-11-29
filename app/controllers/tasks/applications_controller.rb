class Tasks::ApplicationsController < ApplicationController
  before_action :set_task, only: [ :create, :destroy ]

  def create
    authorize! :read, @task
    @application = TaskApplication.new(task_id: params[:task_id], user_id: current_user.id)
    @application.save!
  end


  def destroy
    authorize! :read, @task
    @application = TaskApplication.find([ @task.id, current_user.id ])
    @application.destroy
  end

  private

  def set_task
    @task = Task.find(params[:task_id])
  end
end
