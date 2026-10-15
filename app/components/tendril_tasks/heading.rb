# frozen_string_literal: true

module TendrilTasks
  class Heading < TendrilTasks::Component
    base "group leading-none tracking-tight"

    variant :scheme, default: :level1, values: {
      level1: "mb-4",
      level2: "mb-4",
      level3: "mb-4",
      level4: "mb-4",
      level5: "mb-2",
      level6: "mb-2"
    }

    # Line heights of the responsive font sizes in Gustwave::Heading. With
    # Tailwind CSS v3, responsive font sizes overrode +leading-none+, so these
    # restore the previous look on larger screens.
    toggle :responsive, per: :scheme, values: {
      level1: "md:leading-none lg:leading-none",
      level2: "md:leading-10 lg:leading-none",
      level3: "md:leading-9 lg:leading-10",
      level4: "md:leading-8 lg:leading-9",
      level5: "md:leading-7 lg:leading-8",
      level6: "md:leading-7 lg:leading-7"
    }

    toggle :hyphenated, "hyphens-auto"

    TAG_SCHEME_MAPPINGS = {
      h1: :level2,
      h2: :level3,
      h3: :level4,
      h4: :level5,
      h5: :level6,
      h6: :level6
    }

    def initialize(
      text = nil,
      tag:,
      scheme: nil,
      responsive: true,
      hyphenated: true,
      **options
    )
      @text = text

      tag = fetch_or_fallback(Gustwave::Heading::TAG_OPTIONS,
                              tag,
                              Gustwave::Heading::DEFAULT_TAG)

      # Derive scheme from the tag if not provided
      scheme ||= TAG_SCHEME_MAPPINGS[tag]

      style_with(scheme:, responsive:, hyphenated:)
      @config = { tag:, scheme:, responsive:, lang: (I18n.locale if hyphenated) }
                  .merge(attributes_for(options))
    end

    def call
      render Gustwave::Heading.new(**config) do
        text_or_content
      end
    end

    private

    attr_reader :text, :config
  end
end
