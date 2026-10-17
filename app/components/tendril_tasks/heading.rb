# frozen_string_literal: true

module TendrilTasks
  class Heading < TendrilTasks::Component
    base "group leading-none tracking-tight"

    variant :size, default: :"2xl", values: {
      "2xl": "mb-4",
      xl: "mb-4",
      lg: "mb-4",
      md: "mb-4",
      sm: "mb-2",
      xs: "mb-2"
    }

    # Line heights of the responsive font sizes in Gustwave::Heading. With
    # Tailwind CSS v3, responsive font sizes overrode +leading-none+, so these
    # restore the previous look on larger screens.
    toggle :responsive, per: :size, values: {
      "2xl": "md:leading-none lg:leading-none",
      xl: "md:leading-10 lg:leading-none",
      lg: "md:leading-9 lg:leading-10",
      md: "md:leading-8 lg:leading-9",
      sm: "md:leading-7 lg:leading-8",
      xs: "md:leading-7 lg:leading-7"
    }

    toggle :hyphenated, "hyphens-auto"

    TAG_SIZE_MAPPINGS = {
      h1: :xl,
      h2: :lg,
      h3: :md,
      h4: :sm,
      h5: :xs,
      h6: :xs
    }

    def initialize(
      text = nil,
      tag:,
      size: nil,
      responsive: true,
      hyphenated: true,
      **options
    )
      @text = text

      tag = fetch_or_fallback(TAG_SIZE_MAPPINGS.keys, tag, Gustwave::Heading.option_default(:tag))

      # Derive size from the tag if not provided
      size ||= TAG_SIZE_MAPPINGS[tag]

      select_options(size:, responsive:, hyphenated:)
      @config = { tag:, size:, responsive:, lang: (I18n.locale if hyphenated) }
                  .merge(attributes_for(options))
    end

    def call
      render Gustwave::Heading.new(**config) do
        text_or_content(text)
      end
    end

    private

    attr_reader :text, :config
  end
end
