class Users::OmniauthCallbacksController < ApplicationController
  # OmniAuth callback requests are not a valid return location.
  skip_return_location_storage

  def rocketchat
    auth = request.env["omniauth.auth"]
    @user = User.from_omniauth(auth)

    if @user.persisted?
      @user.remember_me = true
      sign_in @user, event: :authentication
      DownloadAvatarJob.perform_later(@user)
      redirect_to_stored_location
    elsif @user.errors.of_kind?(:email, :taken)
      redirect_to new_user_session_path, alert: t(".email_taken")
    else
      redirect_to new_user_session_path, alert: t(".invalid")
    end
  end

  def failure
    redirect_to root_path, alert: t(".failure")
  end
end
