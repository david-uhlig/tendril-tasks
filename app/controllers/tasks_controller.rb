class TasksController < ApplicationController
  before_action :set_task, only: [ :show, :edit, :update, :destroy ]
  authorize_resource
  before_action :set_task_form, only: [ :edit, :update ]

  rescue_from CanCan::AccessDenied, with: :access_denied_handler

  def index
    filter = params.permit(:project_id)
    @type = :all_published_tasks

    @projects = Project.select(:id, :title)
                       .publicly_visible
                       .order(:updated_at)

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
    if can?(:coordinate, @task)
      @task_applications = TaskApplication
                             .where(task: @task)
                             .includes(:user, :task)
                             .order(created_at: :desc)
    end
  end

  def new
    @task_form = TaskForm.new
    @task_form.coordinators << current_user
  end

  def create
    @task_form = TaskForm.new(task_form_params)

    if @task_form.save
      success_msg = toast_message_for(@task_form.task, :create)
      if @task_form.submit_type == "save_and_new"
        redirect_to new_task_from_preset_path(project_id: @task_form.project.id, coordinator_ids: @task_form.project.coordinators.join("-")), notice: success_msg
      else
        redirect_to task_path(@task_form.task), notice: success_msg
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    @task_form.assign_attributes(task_form_params)
    task_has_changed = @task_form.changed?

    if @task_form.save
      update_msg = toast_message_for(@task_form.task, :update) if task_has_changed
      redirect_to task_path(@task_form.task), notice: update_msg
    else
      render :edit, status: :unprocessable_entity
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
    params[:task_form][:coordinator_ids] = params[:assigned_coordinator_ids]
    params.require(:task_form)
          .permit(:project_id, :title, :description, :publish, :submit_type, coordinator_ids: [])
  end
end
