class Users::OmniauthCallbacksController < ApplicationController
  def rocketchat
    auth = request.env["omniauth.auth"]
    @user = User.from_omniauth(auth)

    if @user.persisted?
      sign_in @user, event: :authentication
      back_or_root = session.delete(:redirect_back_to) || root_path
      redirect_to back_or_root
    else
      session["devise.rocketchat_data"] = auth.except(:extra)
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
    end
  end

  def failure
    redirect_to root_path, alert: "Failure. Please try again."
  end
end
