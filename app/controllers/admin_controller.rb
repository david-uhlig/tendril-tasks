class AdminController < ApplicationController
  # TODO add authorization
  def index
    authorize! :show, :admin_settings
    @users = User.order(role: :desc, name: :asc)
  end
end
