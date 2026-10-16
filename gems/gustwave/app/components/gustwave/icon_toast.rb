# frozen_string_literal: true

module Gustwave
  class IconToast < Gustwave::Component
    base "inline-flex items-center justify-center shrink-0 w-8 h-8 rounded-lg"
    unstyled status: :none

    # The default is also the fallback for unknown statuses in production, e.g.
    # for an unknown flash type.
    variant :status, default: :info, values: {
      info: "text-blue-500 bg-blue-100 dark:bg-blue-800 dark:text-blue-200",
            notice: "text-blue-500 bg-blue-100 dark:bg-blue-800 dark:text-blue-200",
            success: "text-green-500 bg-green-100 dark:bg-green-800 dark:text-green-200",
            error: "text-red-500 bg-red-100 dark:bg-red-800 dark:text-red-200",
            failure: "text-red-500 bg-red-100 dark:bg-red-800 dark:text-red-200",
            warning: "text-orange-500 bg-orange-100 dark:bg-orange-700 dark:text-orange-200",
      alert: "text-orange-500 bg-orange-100 dark:bg-orange-700 dark:text-orange-200"
    }

    # The icon per status, none for :none
    derive :icon, from: :status, values: {
      info: :info_circle,
      notice: :info_circle,
      success: :check_circle,
      error: :close_circle,
      failure: :close_circle,
      warning: :exclamation_circle,
      alert: :exclamation_circle
    }

    def initialize(text = nil,
                   id: nil,
                   status: DEFAULT,
                   position: DEFAULT,
                   dismissible: true,
                   auto_remove: false,
                   icon: nil,
                   **options)
      # Pass-thru to Toast component
      @id = id
      @dismissible = dismissible
      @auto_remove = auto_remove
      @position = position

      @text = text

      select_options(status:)
      @status = option_value(:status)
      @icon = icon.presence || derived_value(:icon)
      @options = attributes_for(options)
    end
  end
end
