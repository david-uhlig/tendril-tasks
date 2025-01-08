# frozen_string_literal: true

module Gustwave
  class IconToast < Gustwave::Component
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
                   id: nil,
                   scheme: :success,
                   position: :none,
                   dismissible: true,
                   icon: nil,
                   **options)
      # Pass-thru to Toast component
      @id = id
      @dismissible = dismissible
      @position = position

      @text = text
      @icon = icon.presence || fetch_icon_by(scheme: scheme)
      @scheme = scheme

      options.deep_symbolize_keys!
      layers = {}
      layers[:base] = :on unless scheme == :none
      layers[:scheme] = scheme
      layers[:custom] = options.delete(:class)
      options[:class] = styles(**layers)
      @options = options
    end

    private

    def fetch_icon_by(scheme:)
      SCHEME_ICON_MAPPINGS[
        fetch_or_fallback(SCHEME_ICON_OPTIONS, scheme, DEFAULT_ICON)
      ]
    end
  end
end
