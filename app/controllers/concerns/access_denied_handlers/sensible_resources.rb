# frozen_string_literal: true

module AccessDeniedHandlers
  module SensibleResources
    extend ActiveSupport::Concern

    included do
      rescue_from CanCan::AccessDenied, with: :access_denied_handler
    end

    private

    # Handles unauthorized requests to sensible resources.
    #
    # ### Usage:
    #   rescue_from CanCan::AccessDenied, with: :access_denied_handler
    #
    # @param [CanCan::AccessDenied] exception The exception that was raised when an unauthorized request was made.
    # @see https://github.com/CanCanCommunity/cancancan/blob/develop/docs/handling_access_denied.md#danger-of-exposing-sensible-information
    def access_denied_handler(exception)
      case exception.action
      when :index
        redirect_back_or_to root_path,
                            notice: t("toast_notification.login_required"),
                            status: :found
      when :new, :create
        redirect_to exception.subject || root_path,
                    notice: t("toast_notification.access_denied"),
                    status: :found
        nil
      when :show, :edit, :update, :destroy
        not_found! # Don't expose it whether a resource exists
      else
        not_found!
      end
    end

    # Raises a routing error for unauthorized resource access.
    #
    # @return [void]
    def not_found!
      respond_to do |format|
        format.turbo_stream { render body: nil, status: :not_found }
        format.html { raise ActionController::RoutingError.new("Not Found") }
      end
    end
  end
end
