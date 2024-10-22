class Users::ProfileController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[edit destroy]

  def edit
  end

  def destroy
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
