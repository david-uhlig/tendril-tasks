class ProjectsController < ApplicationController
  before_action :set_project, only: [ :show, :edit, :update, :destroy ]
  authorize_resource
  before_action :set_project_form, only: [ :edit, :update ]

  rescue_from CanCan::AccessDenied, with: :access_denied_handler

  def index
    @projects = Project.accessible_by(current_ability)
                       .includes(:coordinators)
  end

  def show
    @tasks = Task.accessible_by(current_ability)
                 .where(project: @project)
                 .includes(:coordinators, :applicants, :project)
  end

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
        redirect_to project_path(@project_form.project), notice: "Project was successfully created."
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
      flash[:notice] = "Project #{@project_form.title} was updated." if project_has_changed
      redirect_to project_path(@project_form.project)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    flash[:notice] = "Project #{@project.title} was deleted."
    @project.destroy
    redirect_to projects_path
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

  # TODO replace with pundit
  def check_permission
    unless @project.coordinators.include?(current_user)
      redirect_to projects_path, alert: "Das darfst du nicht."
    end
  end
end
