class Tasks::ApplicationsController < ApplicationController
  # Amount of time that must elapse after the application is submitted before
  # a notification is sent. Provides applicants an opportunity to review, edit,
  # or withdraw the application before the notification is dispatched to
  # coordinators.
  NOTIFICATION_DELAY = 30.minutes
  # Amount of time in that the application is editable by the applicant.
  GRACE_PERIOD = NOTIFICATION_DELAY

  before_action :set_task, only: [ :create, :destroy, :update ]
  before_action :set_origin, only: [ :create, :destroy ]

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
    # TODO generate notification
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

    if @application.editable?
      @application.destroy!
    else
      @application.withdraw
      @application.save!
    end
  end

  private

  def set_task
    @task = Task.find(params[:task_id])
  end

  def set_origin
    case
    when request.referer.include?("tasks/#{@task.id}")
      @origin = :show
    else
      @origin = :index
    end
  end
end
