# frozen_string_literal: true

module Users
  # Signs in as any registered user without going through Rocket.Chat.
  #
  # Only available in local environments (development and test) to ease manual
  # testing with different users and roles. The route is not drawn in
  # production; the guard below is an additional safety net.
  class DevSessionsController < ApplicationController
    skip_return_location_storage

    before_action :ensure_local_environment

    def create
      user = User.find_by(id: params[:user_id])

      if user
        user.remember_me = true
        sign_in user, event: :authentication
        redirect_to_stored_location
      else
        redirect_to new_user_session_path, alert: t(".failure")
      end
    end

    private

    def ensure_local_environment
      head :not_found unless Rails.env.local?
    end
  end
end
