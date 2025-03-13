class ProjectsController < ApplicationController
  before_action :set_project, only: [ :show, :edit, :update, :destroy ]
  authorize_resource
  before_action :set_project_form, only: [ :edit, :update ]

  rescue_from CanCan::AccessDenied, with: :access_denied_handler

  def index
    @projects = Project.publicly_visible
                       .includes(:coordinators)
  end

  def show
    @tasks = Task.publicly_visible
                 .includes(:coordinators, :project, :applicants)
  end

  def new
    @project_form = ProjectForm.new
    @project_form.coordinators << current_user
  end

  def create
    @project_form = ProjectForm.new(project_form_params)

    if @project_form.save
      success_msg = toast_message_for(@project_form.project, :create)
      if @project_form.submit_type == "save_and_new_task"
        redirect_to new_task_from_preset_path(
                      project_id: @project_form.project.id,
                      coordinator_ids: @project_form.project.coordinator_ids.join("-")),
                    notice: success_msg
      else
        redirect_to project_path(@project_form.project), notice: success_msg
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    @project_form.assign_attributes(project_form_params)
    project_has_changed = @project_form.changed?

    if @project_form.save
      update_msg = toast_message_for(@project_form.project, :update) if project_has_changed
      redirect_to project_path(@project_form.project), notice: update_msg
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy

    destroy_msg = toast_message_for(@project, :destroy)
    redirect_to projects_path, notice: destroy_msg
  end

  private

  def project_form_params
    params[:project_form][:coordinator_ids] = params.delete(:assigned_coordinator_ids)
    params.require(:project_form)
          .permit(:title, :description, :publish, :submit_type, coordinator_ids: [])
  end

  def set_project
    @project = Project.includes(:coordinators).find(params[:id])
  end

  def set_project_form
    @project_form = ProjectForm.new(@project)
  end
end
