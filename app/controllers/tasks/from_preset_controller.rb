# frozen_string_literal: true

module Tasks
  class FromPresetController < ApplicationController
    rescue_from CanCan::AccessDenied, with: :access_denied_handler

    def new
      authorize! :create, Task

      @task_form = TaskForm.new(preset_params)

      lookup_context.prefixes.prepend("tasks")
      render "tasks/new"
    end

    private

    def preset_params
      return nil unless params[:project_id].present?

      preset = {}
      preset[:project_id] = params[:project_id]
      preset[:coordinator_ids] = params[:coordinator_ids].split("-")
      preset
    end
  end
end
