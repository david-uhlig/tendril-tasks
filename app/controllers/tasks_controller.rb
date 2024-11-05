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
end
