# frozen_string_literal: true

module ToastNotificationsHelper
  include Primer::FetchOrFallbackHelper

  ACTION_OPTIONS = [ :create, :update, :destroy ].freeze
  STATUS_OPTIONS = [ :success ].freeze

  # Generate an I18n toast message for a resource action
  #
  # @param [ActiveRecord::Base] resource The resource object that the action was performed on.
  # @param [Symbol] action The action that was performed on the resource. One of: :create, :update, :destroy.
  # @param [Symbol] status The status of the action. One of: :success.
  def toast_message_for(resource, action, status: :success)
    unless Rails.env.production?
      raise ArgumentError, "Unknown resource: #{resource}" unless resource.class.respond_to?(:model_name)
    end

    action = fetch_or_fallback(ACTION_OPTIONS, action, :fallback)
    status = fetch_or_fallback(STATUS_OPTIONS, status, :success)

    resource_name = resource&.class&.model_name&.human || t("toast_notification.resource.fallback_name")
    t("toast_notification.#{action}.#{status}", resource: resource_name)
  end
end
