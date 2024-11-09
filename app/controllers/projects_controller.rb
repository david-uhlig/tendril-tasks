class ProjectsController < ApplicationController
  def new
    @project_form = ProjectForm.new
    @project_form.coordinators << current_user
  end
end
