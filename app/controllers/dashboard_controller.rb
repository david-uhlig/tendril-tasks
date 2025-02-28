class DashboardController < ApplicationController
  def index
    @applications = current_user.task_applications
                                .where.not(status: :withdrawn)
                                .order(created_at: :desc)
  end
end
