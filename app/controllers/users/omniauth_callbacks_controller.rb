class Users::OmniauthCallbacksController < ApplicationController
  def rocketchat
    auth = request.env["omniauth.auth"]
    @user = User.from_omniauth(auth)

    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", kind: "Rocket.Chat"
      sign_in_and_redirect @user, event: :authentication
    else
      session["devise.rocketchat_data"] = auth.except(:extra)
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
    end
  end

  def failure
    redirect_to root_path, alert: "Failure. Please try again."
  end
end
