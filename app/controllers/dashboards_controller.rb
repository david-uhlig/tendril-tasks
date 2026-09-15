class DashboardsController < ApplicationController
  def show
    @applications = current_user
      .task_applications
      .where.not(status: :withdrawn)
      .order(created_at: :desc)
  end
end
