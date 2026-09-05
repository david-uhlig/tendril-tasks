# frozen_string_literal: true

class AdminController < ApplicationController
  # Ensures that authorization is performed in every inherited controller
  # action. Skip this check by adding `skip_authorization_check` to that
  # controller.
  # @see https://github.com/CanCanCommunity/cancancan/blob/develop/docs/changing_defaults.md#check_authorization
  check_authorization
  authorize_resource :admin_settings, class: false
  rescue_from CanCan::AccessDenied, with: :access_denied_handler

  private

  # Handles unauthorized requests to admin resources.
  #
  # @param [CanCan::AccessDenied] exception The exception that was raised when an unauthorized request was made.
  def access_denied_handler(exception)
    # `exception.action` returns :show for :index action for unknown reasons.
    # Using `params[:action]` as a fallback.
    case params[:action].to_sym
    when :index, :new, :create
      redirect_back_or_to root_path, notice: t("toast_notification.access_denied"), status: :found
    else
      not_found! # Don't expose it whether a resource exists.
    end
  end
end
