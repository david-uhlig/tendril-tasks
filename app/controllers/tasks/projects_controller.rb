# frozen_string_literal: true

module Tasks
  # Creates an initiative from the modal of the task form, so the task form
  # keeps its entries. The current user becomes the initiative's coordinator.
  class ProjectsController < ::ApplicationController
    rescue_from CanCan::AccessDenied, with: :access_denied_handler

    def create
      authorize! :create, Project

      @project_form = ProjectForm.new(project_form_params.merge(coordinator_ids: [ current_user.id ]))

      respond_to do |format|
        if @project_form.save
          format.turbo_stream
        else
          format.turbo_stream { render :create, status: :unprocessable_content }
        end
      end
    end

    private

    def project_form_params
      params.require(:project_form).permit(:title, :description, :publish)
    end

    def access_denied_handler(exception)
      respond_to do |format|
        format.turbo_stream { head :forbidden }
      end
    end
  end
end
