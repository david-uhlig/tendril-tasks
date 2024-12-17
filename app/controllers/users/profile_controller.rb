class Users::ProfileController < ApplicationController
  before_action :set_user, only: [ :edit, :destroy ]

  rescue_from CanCan::AccessDenied, with: :access_denied_handler

  def edit
    authorize! :edit, @user
  end

  def destroy
    authorize! :destroy, @user
    if @user.destroy
      reset_session # Log the user out after account deletion
      redirect_to root_path, notice: t(".success")
    else
      redirect_to profile_path, alert: t(".failure")
    end
  end

  private

  def set_user
    @user = current_user
  end
end
