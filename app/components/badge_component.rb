# frozen_string_literal: true

# Renders badges with various styles, sizes, and optional borders.
class BadgeComponent < ApplicationComponent
  DEFAULT_SCHEME = :default
  # Mappings of available color schemes to their corresponding CSS classes
  SCHEME_MAPPINGS = {
    default: "bg-blue-100 text-blue-800 me-2 px-2.5 py-0.5 rounded dark:bg-blue-900 dark:text-blue-300",
    dark: "bg-gray-100 text-gray-800 me-2 px-2.5 py-0.5 rounded dark:bg-gray-700 dark:text-gray-300",
    red: "bg-red-100 text-red-800 me-2 px-2.5 py-0.5 rounded dark:bg-red-900 dark:text-red-300",
    green: "bg-green-100 text-green-800 me-2 px-2.5 py-0.5 rounded dark:bg-green-900 dark:text-green-300",
    yellow: "bg-yellow-100 text-yellow-800 me-2 px-2.5 py-0.5 rounded dark:bg-yellow-900 dark:text-yellow-300",
    indigo: "bg-indigo-100 text-indigo-800 me-2 px-2.5 py-0.5 rounded dark:bg-indigo-900 dark:text-indigo-300",
    purple: "bg-purple-100 text-purple-800 me-2 px-2.5 py-0.5 rounded dark:bg-purple-900 dark:text-purple-300",
    pink: "bg-pink-100 text-pink-800 me-2 px-2.5 py-0.5 rounded dark:bg-pink-900 dark:text-pink-300"
  }
  SCHEME_OPTIONS = SCHEME_MAPPINGS.keys

  DEFAULT_SIZE = :extra_small
  # Mappings of available sizes to their corresponding CSS classes
  SIZE_MAPPINGS = {
    extra_small: "text-xs font-medium",
    small: "text-sm font-medium",
    medium: "text-base font-semibold",
    large: "text-lg font-semibold",
    extra_large: "text-xl font-bold",
    xl2: "text-2xl font-extrabold"
  }
  # List of valid size options
  SIZE_OPTIONS = SIZE_MAPPINGS.keys

  # Mappings of border styles to their corresponding CSS classes, keyed by scheme
  # Applied when `border` option is set to truthy
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

  # Initializes the BadgeComponent
  # @param text [String, nil] Optional text to display within the badge.
  # @param scheme [Symbol] The color scheme for the badge. Defaults to `:default`.
  # @param size [Symbol] The size of the badge. Defaults to `:extra_small`.
  # @param border [Boolean] Whether the badge includes a border. Defaults to `false`.
  # @param options [Hash] Additional HTML options passed to the component.
  def initialize(text = nil, scheme: DEFAULT_SCHEME, size: DEFAULT_SIZE, border: false, **options)
    @text = text
    @options = build_options(options, scheme, size, border)
  end

  def call
    tag.span **@options do
      @text || content
    end
  end

  private

  # Builds the options hash for the badge
  # @param options [Hash] Additional HTML options.
  # @param scheme [Symbol] The selected color scheme.
  # @param size [Symbol] The selected size.
  # @param border [Boolean] Whether to include a border.
  # @return [Hash] The finalized options hash with computed classes.
  def build_options(options, scheme, size, border)
    scheme = fetch_or_fallback(SCHEME_OPTIONS, scheme, DEFAULT_SCHEME).to_sym
    border_classes = BORDER_MAPPINGS[scheme] if border

    options.stringify_keys!
    options["class"] = class_names(
      SCHEME_MAPPINGS[scheme],
      border_classes,
      SIZE_MAPPINGS[fetch_or_fallback(SIZE_OPTIONS, size, DEFAULT_SIZE)],
      options.delete("class")
    )
    options.symbolize_keys!
  end
end
