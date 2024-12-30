# frozen_string_literal: true

module Gustwave
  class Heading < Gustwave::Component
    DEFAULT_TAG = :h2
    TAG_OPTIONS = [ :h1, :h2, :h3, :h4, :h5, :h6 ].freeze

    style_layer :base, {
      on: "text-gray-900 dark:text-white",
      off: ""
    }, default: :on

    style_layer :scheme, {
      none: "",
      level1: "text-6xl font-extrabold",
      level2: "text-5xl font-extrabold",
      level3: "text-4xl font-bold",
      level4: "text-3xl font-bold",
      level5: "text-2xl font-semibold",
      level6: "text-xl font-semibold"

    }, default: :level1

    style_layer :responsive_scheme, {
      none: "",
      level1: "text-4xl md:text-5xl lg:text-6xl",
      level2: "text-3xl md:text-4xl lg:text-5xl",
      level3: "text-2xl md:text-3xl lg:text-4xl",
      level4: "text-xl md:text-2xl lg:text-3xl",
      level5: "text-lg md:text-xl lg:text-2xl",
      level6: "text-base md:text-lg lg:text-xl"
    }, default: :none

    def initialize(text = nil,
                   tag:,
                   scheme: default_layer_state(:scheme),
                   responsive: false,
                   **options)
      @text = text
      @tag = fetch_or_fallback(TAG_OPTIONS, tag, DEFAULT_TAG)

      @options = options.symbolize_keys!

      layers = {}
      layers[:base] = :on unless scheme == :none
      layers[:scheme] = scheme
      layers[:responsive_scheme] = scheme if responsive
      layers[:custom] = @options.delete(:class)

      @options[:class] = merge_layers(**layers)
    end

    def call
      content_tag @tag, @options do
        @text || content
      end
    end

    private

    def before_render
      @options[:id] ||= helpers.strip_tags(@text || content).parameterize
    end
  end
end
