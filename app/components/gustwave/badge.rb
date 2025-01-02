# frozen_string_literal: true

module Gustwave
  class Badge < Gustwave::Component
    style :base,
          "px-2.5 py-0.5 rounded whitespace-nowrap"

    style :scheme,
          default: :default,
          states: {
            none: "",
            default: "bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-300",
            dark: "bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300",
            red: "bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-300",
            green: "bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300",
            yellow: "bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-300",
            indigo: "bg-indigo-100 text-indigo-800 dark:bg-indigo-900 dark:text-indigo-300",
            purple: "bg-purple-100 text-purple-800 dark:bg-purple-900 dark:text-purple-300",
            pink: "bg-pink-100 text-pink-800 dark:bg-pink-900 dark:text-pink-300"
          }
    SCHEME_OPTIONS = layer_states(:scheme).keys.excluding(:none).freeze

    style :size,
          default: :xs,
          states: {
            xs: "text-xs font-medium",
            sm: "text-sm font-medium",
            md: "text-base font-semibold",
            lg: "text-lg font-semibold",
            xl: "text-xl font-bold",
            "2xl": "text-2xl font-extrabold"
          }

    style :border,
          default: :default,
          states: {
            none: "",
            default: "border border-blue-400",
            dark: "border border-gray-500",
            red: "border border-red-400",
            green: "border border-green-400",
            yellow: "border border-yellow-300",
            indigo: "border border-indigo-400",
            purple: "border border-purple-400",
            pink: "border border-pink-400"
          }

    style :pill,
          "rounded-full",
          default: :off

    # @param text [String, nil] Optional text to display within the badge.
    # @param tag [Symbol] The HTML tag to use for the badge. Defaults to `:span`.
    # @param scheme [Symbol] The color scheme for the badge. Defaults to `:default`.
    # @param size [Symbol] The size of the badge. Defaults to `:xs`.
    # @param border [Boolean] Whether the badge includes a border. Defaults to `false`.
    # @param pill [Boolean] Rounds the Badge corners to make it look like a pill. Defaults to `false`.
    # @param options [Hash] Additional HTML options passed to the component.
    def initialize(text = nil,
                   tag: :span,
                   scheme: default_layer_state(:scheme),
                   size: default_layer_state(:size),
                   border: false,
                   pill: false,
                   **options)
      @text = text
      @tag = tag

      scheme = scheme.to_sym

      @options = options.symbolize_keys!

      layers = {}
      layers[:base] = :on unless scheme == :none
      layers[:scheme] = scheme
      layers[:border] = scheme if fetch_or_fallback_boolean(border, false)
      layers[:pill] = fetch_or_fallback_boolean(pill, false)
      layers[:size] = size
      layers[:custom] = options.delete(:class)

      @options[:class] = styles(**layers)
    end

    def call
      content_tag @tag, @options do
        @text || content
      end
    end
  end
end
