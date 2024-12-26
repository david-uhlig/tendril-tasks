# frozen_string_literal: true

module TendrilTasks
  class Heading < TendrilTasks::Component
    DEFAULT_CLASSES = "group leading-none tracking-tight"

    TAG_SCHEME_MAPPINGS = {
      h1: :level2,
      h2: :level3,
      h3: :level4,
      h4: :level5,
      h5: :level6,
      h6: :level6
    }

    SCHEME_MAPPINGS = {
      none: "",
      level1: "mb-4",
      level2: "mb-4",
      level3: "mb-4",
      level4: "mb-4",
      level5: "mb-2",
      level6: "mb-2"
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

      scheme ||= TAG_SCHEME_MAPPINGS[tag]
      scheme = fetch_or_fallback(Gustwave::Heading::SCHEME_OPTIONS,
                                 scheme,
                                 Gustwave::Heading::DEFAULT_SCHEME)

      @options ||= {}
      @options[:tag] ||= tag
      @options[:scheme] ||= scheme
      @options[:responsive] ||= responsive
      @options[:class] = class_merge(
        DEFAULT_CLASSES,
        SCHEME_MAPPINGS[scheme],
        options.delete(:class)
      )
    end

    def call
      render Gustwave::Heading.new(**@options) do
        @text || content
      end
    end
  end
end
