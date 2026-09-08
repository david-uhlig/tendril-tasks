class Users::OmniauthCallbacksController < ApplicationController
  # OmniAuth callback requests are not a valid return location.
  skip_return_location_storage

  def rocketchat
    auth = request.env["omniauth.auth"]
    @user = User.from_omniauth(auth)

    if @user.persisted?
      @user.remember_me = true
      sign_in @user, event: :authentication
      redirect_to_stored_location
    else
      session["devise.rocketchat_data"] = auth.except(:extra)
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
    end
  end

  def failure
    redirect_to root_path, alert: t(".failure")
  end
end
