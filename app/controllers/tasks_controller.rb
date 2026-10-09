class TasksController < ApplicationController
  include AccessDeniedHandlers::SensibleResources

  before_action :set_task, only: [ :show, :edit, :update, :destroy ]
  authorize_resource
  before_action :set_task_form, only: [ :edit, :update ]

  def index
    filter = params.permit(:project_id)
    @type = :all_published_tasks

    @projects = Project.select(:id, :title)
                       .publicly_visible
                       .order_by_most_recently_published_task

    @tasks = Task.publicly_visible
                 .includes(:coordinators, :project, :applicants)

    # Apply filters
    if filter[:project_id].present?
      @type = :tasks_for_project
      # Raises an ActiveRecord::RecordNotFound exception when trying to access
      # a non-existing or non-authorized project
      @selected_project = @projects.find(filter[:project_id])
      # Apply project filter
      @tasks = @tasks.where(project_id: filter[:project_id])
    end

    @tasks = @tasks.order(created_at: :desc)
  end

  def show
    @application = current_user.application_for(@task)

    if can?(:coordinate, @task)
      @task_applications = TaskApplication
                             .where(task: @task)
                             .includes(:user, :task)
                             .order(created_at: :desc)
    end
  end

  def new
    @task_form = TaskForm.new(coordinator_ids: [ current_user.id ])
  end

  def create
    @task_form = TaskForm.new(task_form_params)

    if @task_form.save
      success_msg = toast_message_for(@task_form.task, :create)
      if submit_type == "save_and_new"
        redirect_to new_task_from_preset_path(project_id: @task_form.project.id, coordinator_ids: @task_form.task.coordinator_ids.join("-")), notice: success_msg
      else
        redirect_to task_path(@task_form.task), notice: success_msg
      end
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit; end

  def update
    @task_form.assign_attributes(task_form_params)

    if @task_form.save
      update_msg = toast_message_for(@task_form.task, :update) if @task_form.saved_changes?
      redirect_to task_path(@task_form.task), notice: update_msg
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @task.destroy
    redirect_to tasks_path, notice: toast_message_for(@task, :destroy)
  end

  private

  def set_task
    @task = Task.find(params[:id])
  end

  def set_task_form
    @task_form = TaskForm.new(@task)
  end

  def task_form_params
    task_form = params.require(:task_form)
    task_form[:coordinator_ids] = params[:assigned_coordinator_ids]
    task_form.permit(:project_id, :title, :description, :publish, coordinator_ids: [])
  end

  # Which submit button was used, e.g. "save_and_new".
  def submit_type
    params.dig(:task_form, :submit_type)
  end
end
