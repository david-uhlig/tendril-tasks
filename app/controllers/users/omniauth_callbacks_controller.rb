class Users::OmniauthCallbacksController < ApplicationController
  def rocketchat
    auth = request.env["omniauth.auth"]
    @user = User.from_omniauth(auth)

    if @user.persisted?
      @user.remember_me = true
      sign_in @user, event: :authentication
      redirect_to stored_location_for(:user) || root_path
    else
      session["devise.rocketchat_data"] = auth.except(:extra)
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
    end
  end

  def failure
    redirect_to root_path, alert: t(".failure")
  end

  private

  # Never store OmniAuth callback requests in the session.
  def storable_location?
    false
  end
end
