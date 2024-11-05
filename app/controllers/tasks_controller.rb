class TasksController < ApplicationController
  def index; end

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

  private

  def task_form_params
    params.require(:task_form)
          .permit(:project_id, :title, :description, :publish, :submit_type, coordinator_ids: [])
  end
end
