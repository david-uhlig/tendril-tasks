# frozen_string_literal: true

module AccessDeniedHandlers
  module AdminResources
    extend ActiveSupport::Concern

    included do
      rescue_from CanCan::AccessDenied, with: :access_denied_handler
    end

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
