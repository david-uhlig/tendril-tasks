class Users::ProfileController < ApplicationController
  before_action :set_user, only: [ :edit, :destroy ]

  def edit
    authorize! :edit, @user
  end

  def destroy
    authorize! :destroy, @user
    if @user.destroy
      reset_session # Log the user out after account deletion
      redirect_to root_path, notice: "Dein Konto wurde gelöscht!"
    else
      redirect_to profile_path, alert: "Wir konnten dein Konto nicht löschen. Bitte versuche es nochmals!"
    end
  end

  private

  def set_user
    @user = current_user
  end
end
