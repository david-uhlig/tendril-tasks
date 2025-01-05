# frozen_string_literal: true

module Gustwave
  class Toast < Gustwave::Component
    style :base,
          "inline-flex items-center justify-center flex-shrink-0 w-8 h-8 rounded-lg"

    style :scheme,
          default: :info,
          states: {
            none: "",
            info: "text-blue-500 bg-blue-100 dark:bg-blue-800 dark:text-blue-200",
            success: "text-green-500 bg-green-100 dark:bg-green-800 dark:text-green-200",
            error: "text-red-500 bg-red-100 dark:bg-red-800 dark:text-red-200",
            failure: "text-red-500 bg-red-100 dark:bg-red-800 dark:text-red-200",
            warning: "text-orange-500 bg-orange-100 dark:bg-orange-700 dark:text-orange-200",
            alert: "text-orange-500 bg-orange-100 dark:bg-orange-700 dark:text-orange-200"
          }

    style :position,
          default: :none,
          states: {
            none: "",
            top_left: "fixed top-5 left-5",
            top_center: "fixed top-5 left-1/2 transform -translate-x-1/2",
            top_right: "fixed top-5 right-5",
            bottom_left: "fixed bottom-5 left-5",
            bottom_center: "fixed bottom-5 left-1/2 transform -translate-x-1/2",
            bottom_right: "fixed bottom-5 right-5"
          }

    style :toast_base,
           "flex items-center w-full max-w-xs p-4 text-gray-500 bg-white rounded-lg shadow dark:text-gray-400 dark:bg-gray-800"

    DEFAULT_ICON = default_layer_state(:scheme)
    SCHEME_ICON_MAPPINGS = {
      none: nil,
      info: :info_circle,
      success: :check_circle,
      error: :close_circle,
      failure: :close_circle,
      warning: :exclamation_circle,
      alert: :exclamation_circle
    }
    SCHEME_ICON_OPTIONS = SCHEME_ICON_MAPPINGS.keys

    def initialize(text = nil,
                   scheme: :success,
                   position: :none,
                   dismissible: true,
                   icon: nil,
                   id: nil,
                   **options)
      @text = text
      @icon = icon.presence || SCHEME_ICON_MAPPINGS[fetch_or_fallback(SCHEME_ICON_OPTIONS, scheme, DEFAULT_ICON)]
      @dismissible = fetch_or_fallback_boolean(dismissible, true)
      @id = id.presence || "toast-#{scheme}-#{SecureRandom.alphanumeric(5).downcase}"

      options.deep_symbolize_keys!
      layers = {}
      layers[:base] = :on unless scheme == :none
      layers[:scheme] = scheme
      layers[:custom] = options.delete(:class)
      options[:class] = styles(**layers)

      @toast_options = {}
      @toast_options[:id] = @id
      @toast_options[:class] = styles(toast_base: true,
                                      position: position)
      @toast_options[:role] = "alert"
      @toast_options[:"data-controller"] = options.delete(:"data-controller") || "fade-out-and-remove"
      @options = options
    end
  end
end
