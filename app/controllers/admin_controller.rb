# frozen_string_literal: true

class AdminController < ApplicationController
  include AccessDeniedHandlers::AdminResources

  # Ensures that authorization is performed in every inherited controller
  # action. Skip this check by adding `skip_authorization_check` to that
  # controller.
  # @see https://github.com/CanCanCommunity/cancancan/blob/develop/docs/changing_defaults.md#check_authorization
  check_authorization
  authorize_resource :admin_settings, class: false
end
