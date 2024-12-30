# frozen_string_literal: true

module Gustwave
  class Avatar < Gustwave::Component
    style_layer :scheme, {
      none: "",
      round: "rounded-full",
      square: "rounded"
    }, default: :round

    style_layer :size, {
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
    }, default: :md

    style_layer :border, {
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
    }, default: :md

    def initialize(src:,
                   alt: nil,
                   scheme: style_variant_default(:scheme),
                   size: style_variant_default(:size),
                   border: false,
                   **options)
      @src = src

      options.deep_symbolize_keys!
      layers = {}
      layers[:scheme] = scheme
      layers[:size] = size
      layers[:border] = size if border
      layers[:custom] = options.delete(:class)

      options[:alt] ||= alt
      options[:class] = merge_layers(**layers)
      options[:role] ||= "img"
      @options = options
    end

    def call
      image_tag(@src, **@options)
    end
  end
end
