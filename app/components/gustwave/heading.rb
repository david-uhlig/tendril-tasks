# frozen_string_literal: true

module Gustwave
  class Heading < Gustwave::Component
    DEFAULT_TAG = :h2
    TAG_OPTIONS = [ :h1, :h2, :h3, :h4, :h5, :h6 ].freeze

    styling :base,
            "text-gray-900 dark:text-white"

    styling :scheme,
            default: :level1,
            variations: {
              none: "",
              level1: "text-6xl font-extrabold",
              level2: "text-5xl font-extrabold",
              level3: "text-4xl font-bold",
              level4: "text-3xl font-bold",
              level5: "text-2xl font-semibold",
              level6: "text-xl font-semibold"
            }

    styling :responsive_scheme,
            default: :none,
            variations: {
              none: "",
              level1: "text-4xl md:text-5xl lg:text-6xl",
              level2: "text-3xl md:text-4xl lg:text-5xl",
              level3: "text-2xl md:text-3xl lg:text-4xl",
              level4: "text-xl md:text-2xl lg:text-3xl",
              level5: "text-lg md:text-xl lg:text-2xl",
              level6: "text-base md:text-lg lg:text-xl"
            }

    def initialize(
      text = nil,
      tag:,
      scheme: scheme_styling_default,
      responsive: false,
      **options
    )
      @text = text
      @tag = fetch_or_fallback(TAG_OPTIONS, tag, DEFAULT_TAG)

      @config = configure_html_attributes(
        options,
        class: compose_design(
          base: (true unless scheme == :none),
          scheme:,
          responsive_scheme: (scheme if responsive),
        )
      )
    end

    def before_render
      @config[:id] ||= helpers.strip_tags(text_or_content).parameterize
    end

    def call
      content_tag tag, config do
        text_or_content
      end
    end

    private

    attr_reader :tag, :config, :text
  end
end
