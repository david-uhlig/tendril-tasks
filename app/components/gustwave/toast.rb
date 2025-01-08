# frozen_string_literal: true

module Gustwave
  class Toast < Gustwave::Component
    style :base,
          "flex items-center w-full max-w-xs p-4 text-gray-500 bg-white rounded-lg shadow dark:text-gray-400 dark:bg-gray-800"

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

    def initialize(text = nil,
                   position: :none,
                   id: nil,
                   dismissible: true,
                   **options)
      @text = text
      @id = id.presence || random_id(prefix: "toast")
      @dismissible = fetch_or_fallback_boolean(dismissible, true)

      options.deep_symbolize_keys!
      @options = {}
      @options[:id] = @id
      @options[:class] = styles(base: true,
                                position: position,
                                custom: options.delete(:class))
      @options[:role] = "alert"
      @options.merge!(animate_and_remove_options(options))
    end

    def dismissible?
      @dismissible
    end

    private

    def animate_and_remove_options(options)
      default_options = {}
      default_options[:"data-controller"] = "animate-and-remove"

      custom_data_controller = options.dig(:"data-controller")
      unless custom_data_controller.present? && custom_data_controller != "animate-and-remove"
        default_options[:"data-action"] = [
          "mouseover->animate-and-remove#pause",
          "mouseout->animate-and-remove#continue"
        ].join(" ")
      end

      default_options.merge(options
                          .slice(:"data-controller", :"data-action")
                          .compact)
    end
  end
end
