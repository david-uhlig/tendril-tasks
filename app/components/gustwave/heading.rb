# frozen_string_literal: true

module Gustwave
  class Heading < Gustwave::Component
    DEFAULT_TAG = :h2
    TAG_OPTIONS = [ :h1, :h2, :h3, :h4, :h5, :h6 ].freeze

    DEFAULT_CLASSES = "text-gray-900 dark:text-white"

    DEFAULT_SCHEME = :level1
    SCHEME_MAPPINGS = {
      none: "",
      level1: "text-6xl font-extrabold",
      level2: "text-5xl font-extrabold",
      level3: "text-4xl font-bold",
      level4: "text-3xl font-bold",
      level5: "text-2xl font-semibold",
      level6: "text-xl font-semibold"
    }.freeze
    SCHEME_OPTIONS = SCHEME_MAPPINGS.keys

    RESPONSIVE_SCHEME_MAPPINGS = {
      none: "",
      level1: "text-4xl md:text-5xl lg:text-6xl",
      level2: "text-3xl md:text-4xl lg:text-5xl",
      level3: "text-2xl md:text-3xl lg:text-4xl",
      level4: "text-xl md:text-2xl lg:text-3xl",
      level5: "text-lg md:text-xl lg:text-2xl",
      level6: "text-base md:text-lg lg:text-xl"
    }
    RESPONSIVE_SCHEME_OPTIONS = RESPONSIVE_SCHEME_MAPPINGS.keys

    def initialize(text = nil,
                   tag:,
                   scheme: DEFAULT_SCHEME,
                   responsive: false,
                   **options)
      @text = text
      @tag = fetch_or_fallback(TAG_OPTIONS, tag, DEFAULT_TAG)
      @scheme = fetch_or_fallback(SCHEME_OPTIONS, scheme, DEFAULT_SCHEME)
      @responsive = fetch_or_fallback_boolean(responsive, false)
      @options = build_options(options)
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

    def build_options(options)
      default_classes = DEFAULT_CLASSES unless @scheme == :none
      responsive_classes = RESPONSIVE_SCHEME_MAPPINGS[@scheme] if @responsive

      options.deep_symbolize_keys!
      options[:class] = class_merge(
        default_classes,
        SCHEME_MAPPINGS[@scheme],
        responsive_classes,
        options.delete(:class)
      )
      options
    end
  end
end
