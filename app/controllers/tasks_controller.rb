class TasksController < ApplicationController
  before_action :set_task, only: [ :show, :edit, :update, :destroy ]
  before_action :set_task_form, only: [ :edit, :update ]
  before_action :check_permission, only: [ :edit, :update, :destroy ]

  def index; end

  def show
    # TODO implement
  end

  def new
    @task_form = TaskForm.new(preset_params)
    @task_form.coordinators << current_user unless @task_form.coordinators.present?
  end

  def create
    @task_form = TaskForm.new(task_form_params)

    if @task_form.save
      success_msg = "Task was successfully created."
      if @task_form.submit_type == "save_and_new"
        redirect_to new_task_with_preset_path(project_id: @task_form.project.id, coordinator_ids: @task_form.project.coordinators.join("-")), notice: success_msg
      else
        redirect_to root_path, notice: success_msg
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
    params[:task_form][:coordinator_ids] = params[:assigned_coordinator_ids]
    params.require(:task_form)
          .permit(:project_id, :title, :description, :publish, :submit_type, coordinator_ids: [])
  end

  def preset_params
    return nil unless params[:project_id].present?

    preset = {}
    preset[:project_id] = params[:project_id]
    preset[:coordinator_ids] = params[:coordinator_ids].split("-")
    preset
  end

  # TODO replace with pundit
  def check_permission
    unless @task.coordinators.include?(current_user)
      redirect_to tasks_path, alert: "Das darfst du nicht."
    end
  end
end
