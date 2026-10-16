# frozen_string_literal: true

module Gustwave
  class Heading < Gustwave::Component
    include ActionView::Helpers::SanitizeHelper

    # The id prefix of a heading whose text yields no id, e.g. one made of symbols
    FALLBACK_ID_PREFIX = "heading"

    base "text-gray-900 dark:text-white", unless: { scheme: :none }

    # The HTML tag, i.e. the heading level in the document outline
    option :tag, default: :h2, values: %i[h1 h2 h3 h4 h5 h6]

    variant :scheme, default: :level1, values: {
      level1: "text-6xl font-extrabold",
      level2: "text-5xl font-extrabold",
      level3: "text-4xl font-bold",
      level4: "text-3xl font-bold",
      level5: "text-2xl font-semibold",
      level6: "text-xl font-semibold"
    }

    # Font sizes that grow with the screen
    toggle :responsive, per: :scheme, values: {
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
      scheme: DEFAULT,
      responsive: false,
      **options
    )
      @text = text

      select_options(tag:)
      @tag = option_value(:tag)

      # Derive the scheme from the tag if not given
      scheme = :"level#{@tag.to_s.delete('h')}" if scheme.nil? || scheme.equal?(DEFAULT)
      select_options(scheme:, responsive:)
      @config = attributes_for(options)
    end

    def before_render
      @config[:id] ||= strip_tags(text_or_content).parameterize.presence || "#{FALLBACK_ID_PREFIX}-#{SecureRandom.hex(4)}"
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
