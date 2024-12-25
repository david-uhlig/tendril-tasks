# frozen_string_literal: true

module Gustwave
  class Badge < Gustwave::Component
    DEFAULT_CLASSES = "px-2.5 py-0.5 rounded whitespace-nowrap"

    DEFAULT_SCHEME = :default
    SCHEME_MAPPINGS = {
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
    SCHEME_OPTIONS = SCHEME_MAPPINGS.keys

    DEFAULT_SIZE = :xs
    SIZE_MAPPINGS = {
      xs: "text-xs font-medium",
      sm: "text-sm font-medium",
      md: "text-base font-semibold",
      lg: "text-lg font-semibold",
      xl: "text-xl font-bold",
      "2xl": "text-2xl font-extrabold"
    }
    SIZE_OPTIONS = SIZE_MAPPINGS.keys

    BORDER_MAPPINGS = {
      default: "border border-blue-400",
      dark: "border border-gray-500",
      red: "border border-red-400",
      green: "border border-green-400",
      yellow: "border border-yellow-300",
      indigo: "border border-indigo-400",
      purple: "border border-purple-400",
      pink: "border border-pink-400"
    }
    BORDER_OPTIONS = BORDER_MAPPINGS.keys

    PILL_CLASSES = "rounded-full"

    # @param text [String, nil] Optional text to display within the badge.
    # @param tag [Symbol] The HTML tag to use for the badge. Defaults to `:span`.
    # @param scheme [Symbol] The color scheme for the badge. Defaults to `:default`.
    # @param size [Symbol] The size of the badge. Defaults to `:xs`.
    # @param border [Boolean] Whether the badge includes a border. Defaults to `false`.
    # @param pill [Boolean] Rounds the Badge corners to make it look like a pill. Defaults to `false`.
    # @param options [Hash] Additional HTML options passed to the component.
    def initialize(text = nil,
                   tag: :span,
                   scheme: DEFAULT_SCHEME,
                   size: DEFAULT_SIZE,
                   border: false,
                   pill: false,
                   **options)
      @text = text
      @tag = tag
      @options = build_options(options, scheme, size, border, pill)
    end

    def call
      content_tag @tag, @options do
        @text || content
      end
    end

    private

    # Builds the options hash for the badge
    # @param options [Hash] Additional HTML options.
    # @param scheme [Symbol] The selected color scheme.
    # @param size [Symbol] The selected size.
    # @param border [Boolean] Whether to include a border.
    # @param pill [Boolean] Whether to round the corners to make it look like a pill.
    # @return [Hash] The finalized options hash with computed classes.
    def build_options(options, scheme, size, border, pill)
      scheme = fetch_or_fallback(SCHEME_OPTIONS, scheme, DEFAULT_SCHEME).to_sym
      default_classes = DEFAULT_CLASSES unless scheme == :none
      border_classes = BORDER_MAPPINGS[scheme] if border
      pill_classes = PILL_CLASSES if pill

      options.deep_symbolize_keys!
      options[:class] = class_merge(
        default_classes,
        SCHEME_MAPPINGS[scheme],
        border_classes,
        pill_classes,
        SIZE_MAPPINGS[fetch_or_fallback(SIZE_OPTIONS, size, DEFAULT_SIZE)],
        options.delete(:class)
      )
      options
    end
  end
end
