class AdminController < ApplicationController
  def index
    authorize! :show, :admin_settings
    @users = User.order(role: :desc, name: :asc)
    @stats = Admin::Stats.new
  end
end
