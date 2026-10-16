# frozen_string_literal: true

module Gustwave
  class Heading < Gustwave::Component
    include ActionView::Helpers::SanitizeHelper

    # The id prefix of a heading whose text yields no id, e.g. one made of symbols
    FALLBACK_ID_PREFIX = "heading"

    base "text-gray-900 dark:text-white"
    unstyled size: :none

    # The HTML tag, i.e. the heading level in the document outline
    option :tag, default: :h2, values: %i[h1 h2 h3 h4 h5 h6]

    variant :size, default: :"2xl", values: {
      "2xl": "text-6xl font-extrabold",
      xl: "text-5xl font-extrabold",
      lg: "text-4xl font-bold",
      md: "text-3xl font-bold",
      sm: "text-2xl font-semibold",
      xs: "text-xl font-semibold"
    }

    # The size per tag, when no size is given
    derive :default_size, from: :tag, values: {
      h1: :"2xl",
      h2: :xl,
      h3: :lg,
      h4: :md,
      h5: :sm,
      h6: :xs
    }

    # Font sizes that grow with the screen
    toggle :responsive, per: :size, values: {
      "2xl": "text-4xl md:text-5xl lg:text-6xl",
      xl: "text-3xl md:text-4xl lg:text-5xl",
      lg: "text-2xl md:text-3xl lg:text-4xl",
      md: "text-xl md:text-2xl lg:text-3xl",
      sm: "text-lg md:text-xl lg:text-2xl",
      xs: "text-base md:text-lg lg:text-xl"
    }

    def initialize(
      text = nil,
      tag: DEFAULT,
      size: DEFAULT,
      responsive: false,
      **options
    )
      @text = text

      select_options(tag:)
      @tag = option_value(:tag)

      size = derived_value(:default_size) if size.nil? || size.equal?(DEFAULT)
      select_options(size:, responsive:)
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
