class TasksController < ApplicationController
  before_action :set_task, only: [ :show, :edit, :update, :destroy ]
  before_action :set_task_form, only: [ :edit, :update ]
  before_action :check_permission, only: [ :edit, :update, :destroy ]

  def index; end

  def show
    # TODO implement
  end

  def new
    @task_form = TaskForm.new
    task_preset = GlobalID::Locator.locate_signed(params[:preset])

    # When "save and new" was selected while creating the previous task, keep project and coordinators for convenience.
    if task_preset
      @task_form.project_id = task_preset.project_id
      @task_form.coordinator_ids = task_preset.coordinator_ids
    else
      @task_form.coordinators << current_user
    end
  end

  def create
    @task_form = TaskForm.new(task_form_params)

    if @task_form.save
      task_sgid = @task_form.task.to_signed_global_id(expires_in: 1.minutes)
      redirect_path = @task_form.submit_type == "save_and_new" ? new_task_path(preset: task_sgid) : root_path
      redirect_to redirect_path, notice: "Task was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    @task_form.assign_attributes(task_form_params)
    task_has_changed = @task_form.changed?

    if @task_form.save
      flash[:notice] = "Task #{@task_form.title} was updated." if task_has_changed
      # TODO redirect to show page when implemented
      redirect_to tasks_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
    redirect_to tasks_path
  end

  private

  def set_task
    @task = Task.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to tasks_path
  end

  def set_task_form
    @task_form = TaskForm.new(@task)
  end

  def task_form_params
    params.require(:task_form)
          .permit(:project_id, :title, :description, :publish, :submit_type, coordinator_ids: [])
  end

  # TODO replace with pundit
  def check_permission
    unless @task.coordinators.include?(current_user)
      redirect_to tasks_path, alert: "Das darfst du nicht."
    end
  end
end
