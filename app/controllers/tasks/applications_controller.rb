class Tasks::ApplicationsController < ApplicationController
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

    if @application.persisted?
      NewTaskApplicationNotifier
        .with(record: @application, delay: TaskApplication::NOTIFICATION_DELAY)
        .deliver
    end
  end

  def update
    authorize! :read, @task

    @updated = false
    @application = TaskApplication.find_by(
      task_id: params[:task_id],
      user_id: current_user.id
    )
    if @application.editable?
      @application.comment = params[:task_application][:comment].presence
      @application.save!
      @updated = true
    end
  end

  def destroy
    authorize! :read, @task

    @application = TaskApplication.find_by(
      task_id: @task.id,
      user_id: current_user.id
    )

    # Within the grace period, just delete the application. Coordinators haven't
    # been notified yet.
    if @application.editable?
      @application.destroy!
    # After the grace period, set the application to withdrawn. The application
    # will be still shown to the coordinators with the withdrawn status, until
    # the user reapplies.
    else
      @application.withdraw
      @application.save!
      WithdrawnTaskApplicationNotifier.with(record: @application).deliver
    end
  end

  private

  def set_task
    @task = Task.find(params[:task_id])
  end
end
