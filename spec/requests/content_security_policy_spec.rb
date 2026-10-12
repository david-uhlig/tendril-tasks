# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Content Security Policy", type: :request do
  # The sign in form posts to /users/auth/rocketchat, which redirects to the
  # Rocket.Chat workspace. Browsers block that redirect unless form-action
  # allows the workspace.
  it "allows forms to redirect to the Rocket.Chat workspace" do
    get new_user_session_path

    policy = response.headers["Content-Security-Policy"] ||
             response.headers["Content-Security-Policy-Report-Only"]
    form_action = policy.split(";").map(&:strip).find { |directive| directive.start_with?("form-action ") }

    expect(form_action.split).to include("'self'", RocketChatConfig.origin)
  end
end
