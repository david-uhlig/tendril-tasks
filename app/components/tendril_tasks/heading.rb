# frozen_string_literal: true

module TendrilTasks
  class Heading < TendrilTasks::Component
    style_layer :base, {
      on: "group leading-none tracking-tight",
      off: ""
    }, default: :on

    style_layer :scheme, {
      none: "",
      level1: "mb-4",
      level2: "mb-4",
      level3: "mb-4",
      level4: "mb-4",
      level5: "mb-2",
      level6: "mb-2"
    }, default: :level1

    TAG_SCHEME_MAPPINGS = {
      h1: :level2,
      h2: :level3,
      h3: :level4,
      h4: :level5,
      h5: :level6,
      h6: :level6
    }

    def initialize(text = nil,
                   tag:,
                   scheme: nil,
                   responsive: true,
                   **options)
      @text = text

      tag = fetch_or_fallback(Gustwave::Heading::TAG_OPTIONS,
                              tag,
                              Gustwave::Heading::DEFAULT_TAG)

      # Derive scheme from the tag if not provided
      scheme ||= TAG_SCHEME_MAPPINGS[tag]

      @options = options.deep_symbolize_keys
      @options[:tag] ||= tag
      @options[:scheme] ||= scheme
      @options[:responsive] ||= responsive
      @options[:class] = merge_layers(base: true,
                                      scheme: scheme,
                                      custom: @options.delete(:class))
    end

    def call
      render Gustwave::Heading.new(**@options) do
        @text || content
      end
    end
  end
end
