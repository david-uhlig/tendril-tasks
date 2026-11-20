# frozen_string_literal: true

module Gustwave
  # @status alpha
  class Heading < Gustwave::Component
    include ActionView::Helpers::SanitizeHelper

    # The id prefix of a heading whose text yields no id, e.g. one made of symbols
    FALLBACK_ID_PREFIX = "heading"

    base "text-gray-900 dark:text-white", unless: { size: :none }

    # The HTML tag, i.e. the heading level in the document outline
    option :tag, default: :h2, values: %i[h1 h2 h3 h4 h5 h6]

    variant :size, default: :"2xl", values: {
      "2xl": "text-6xl font-extrabold",
      xl: "text-5xl font-extrabold",
      lg: "text-4xl font-bold",
      md: "text-3xl font-bold",
      sm: "text-2xl font-bold",
      xs: "text-xl font-bold"
    }

    # The size per tag, when no size is given
    derive :default_size, from: :tag, values: {
      h1: :xl,
      h2: :lg,
      h3: :md,
      h4: :sm,
      h5: :xs,
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

    # @param text [String, nil] the text. Without it the block is the content.
    # @param tag [Symbol] the heading level. Defaults to +:h2+. Valid values are +:h1+ to +:h6+.
    # @param size [Symbol] Defaults to the size of the +tag+: +:xl+ for +:h1+, +:lg+ for +:h2+, +:md+ for +:h3+, +:sm+ for +:h4+ and +:xs+ for +:h5+ and +:h6+. Valid values are +:"2xl"+, +:xl+, +:lg+, +:md+, +:sm+, +:xs+ and +:none+, which adds no size classes.
    # @param responsive [Boolean] whether the font size grows with the screen. Defaults to +false+.
    # @param options [Hash] the HTML attributes of the heading. Without an +id+, the id is the parameterized text.
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
      @config[:id] ||= strip_tags(text_or_content(text)).parameterize.presence || "#{FALLBACK_ID_PREFIX}-#{SecureRandom.hex(4)}"
    end

    def call
      content_tag tag, config do
        text_or_content(text)
      end
    end

    private

    attr_reader :tag, :config, :text
  end
end
