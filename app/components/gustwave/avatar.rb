# frozen_string_literal: true

module Gustwave
  class Avatar < Gustwave::Component
    DEFAULT_SCHEME = :round
    SCHEME_MAPPINGS = {
      none: "",
      round: "rounded-full",
      square: "rounded"
    }.freeze
    SCHEME_OPTIONS = SCHEME_MAPPINGS.keys

    DEFAULT_SIZE = :md
    SIZE_MAPPINGS = {
      none: "",
      original: "",
      xs: "w-6 h-6",
      sm: "w-8 h-8",
      md: "w-10 h-10",
      lg: "w-12 h-12",
      xl: "w-16 h-16",
      "2xl": "w-20 h-20",
      "3xl": "w-28 h-28",
      "4xl": "w-36 h-36"
    }.freeze
    SIZE_OPTIONS = SIZE_MAPPINGS.keys

    SIZE_BORDER_MAPPINGS = {
      none: "ring-1 ring-gray-300 dark:ring-gray-500",
      original: "ring-1 ring-gray-300 dark:ring-gray-500",
      xs: "ring-0 ring-gray-300 dark:ring-gray-500",
      sm: "ring-1 ring-gray-300 dark:ring-gray-500",
      md: "ring-2 ring-gray-300 dark:ring-gray-500",
      lg: "ring ring-gray-300 dark:ring-gray-500",
      xl: "ring ring-gray-300 dark:ring-gray-500",
      "2xl": "ring-4 ring-gray-300 dark:ring-gray-500",
      "3xl": "ring-4 ring-gray-300 dark:ring-gray-500",
      "4xl": "ring-8 ring-gray-300 dark:ring-gray-500"
    }

    def initialize(src:,
                   alt: nil,
                   scheme: DEFAULT_SCHEME,
                   size: DEFAULT_SIZE,
                   border: false,
                   **options)
      @src = src
      border = fetch_or_fallback_boolean(border, false)
      @options = build_options(options, alt, scheme, size, border)
    end

    def call
      image_tag(@src, **@options)
    end

    private

    def build_options(options, alt, scheme, size, border)
      border_class = SIZE_BORDER_MAPPINGS[size.to_sym] if border

      options.deep_symbolize_keys!
      options[:alt] ||= alt
      options[:class] = class_merge(
        SCHEME_MAPPINGS[fetch_or_fallback(SCHEME_OPTIONS, scheme, DEFAULT_SCHEME)],
        SIZE_MAPPINGS[fetch_or_fallback(SIZE_OPTIONS, size.to_sym, DEFAULT_SIZE)],
        border_class,
        options.delete(:class)
      )
      options[:role] ||= "img"
      options
    end
  end
end
