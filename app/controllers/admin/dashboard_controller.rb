# frozen_string_literal: true

module Admin
  class DashboardController < AdminController
    def index
      @users = User.order(role: :desc, name: :asc)
      @stats = Admin::Stats.new
    end
  end
end
