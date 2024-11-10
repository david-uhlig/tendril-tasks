class ProjectsController < ApplicationController
  def new
    @project_form = ProjectForm.new
    @project_form.coordinators << current_user
  end

  def create
    @project_form = ProjectForm.new(project_form_params)

    if @project_form.save
      success_msg = "Project successfully created."
      if @project_form.submit_type == "save_and_new_task"
        redirect_to new_task_with_preset_path(project_id: @project_form.project.id, coordinator_ids: @project_form.project.coordinator_ids.join("-")), notice: success_msg
      else
        redirect_to root_path, notice: "Project was successfully created."
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def project_form_params
    params[:project_form][:coordinator_ids] = params.delete(:assigned_coordinator_ids)
    params.require(:project_form)
          .permit(:title, :description, :publish, :submit_type, coordinator_ids: [])
  end
end
