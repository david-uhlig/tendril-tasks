# frozen_string_literal: true

module Gustwave
  # Use Icon to render an SVG icon.
  #
  # The icon is rendered as an +<svg>+ element. The +name+ parameter is used
  # to determine the icon's filename. The +theme+ parameter determines the
  # icon's theme, either +:outline+ or +:solid+, i.e. the path where it's found.
  # Several other parameters can be passed to customize the icon's appearance.
  class Icon < Gustwave::Component
    ICON_PATH = File.join("icons").freeze

    DEFAULT_ICON_THEME = :outline
    ICON_THEME_OPTIONS = [ :outline, :solid ].freeze

    SVG_STROKE_WIDTH = 1.5
    DEFAULT_STROKE_WIDTH = SVG_STROKE_WIDTH

    # Modifies the icon's stroke width. Supply custom values by passing +class: "*:stroke-[10px]"+ through the +options+ hash, where +10px+ is your chosen stroke width.
    style :stroke_width,
          default: "1.5",
          states: {
            "0": "*:stroke-0",
            "0.5": "*:stroke-[0.5px]",
            "1": "*:stroke-1",
            "1.5": "",
            "2": "*:stroke-2",
            "2.5": "*:stroke-[2.5px]",
            "3": "*:stroke-[3px]",
            "3.5": "*:stroke-[3.5px]",
            "4": "*:stroke-[4px]"
          }

    # Modifies the icon's stroke color.
    style :scheme,
          default: :none,
          states: {
            none: "",
            light: "text-white dark:text-gray-800",
            dark: "text-gray-800 dark:text-white"
          }


    # Matches with the +line-height+ property of the +text-*+ utility classes
    # in Tailwind CSS.
    # see: https://tailwindcss.com/docs/font-size
    style :size,
          default: :md,
          states: {
            none: "",
            xs: "h-4 w-4",
            sm: "h-5 w-5",
            md: "h-6 w-6",
            base: "h-6 w-6",
            lg: "h-7 w-7",
            xl: "h-7 w-7",
            "2xl": "h-8 w-8",
            "3xl": "h-9 w-9",
            "4xl": "h-10 w-10",
            "5xl": "h-12 w-12",
            "6xl": "h-14 w-14",
            "7xl": "h-16 w-16",
            "8xl": "h-24 w-24",
            "9xl": "h-32 w-32"
          }

    # Modifies the icon's position. To achieve responsive behavior pass e.g. +class: "ms-0 sm:ms-1.5"+ to the +options+ hash.
    # TODO refactor default to :standalone. Margins are often less flexible than gap utilities on the surround container. Components should default to not display any margin.
    style :position,
          default: :leading,
          states: {
            leading: "me-1.5",
            trailing: "ms-1.5",
            inline: "mx-1.5",
            standalone: ""
          }

    # @param name [Symbol] the icon's identifier. Corresponds to the icons filename, underscores +_+ in the identifier are replaced with dashes +-+, e.g. +:arrow_up+ loads +arrow-up.svg+ in the +ICON_PATH/theme/+ directory.
    # @param theme [Symbol] either +:outline+ or +:solid+.
    # @param scheme [Symbol] +:light+, +:dark+, or +:none+ (default). Color scheme of the SVG's outline.
    # @param size [Symbol] +:xs+, +:sm+, +:md+, +:lg+, +:xl+, +:2xl+, +:3xl+, +:4xl+, +:5xl+, +:6xl+, +:7xl+, +:8xl+, or +:9xl+. Size of the SVG.
    # @param position [Symbol] +:leading+ (default) adds margin after the icon. +:trailing+ adds margin before the icon. +:inline+ adds margin on both sides. +:standalone+ removes margin.
    # @param stroke_width [String] changes the stroke width of the SVG. Supported values are +0+, +0.5+, +1+, +1.5+, +2+, +2.5+, +3+, +3.5+, and +4+. Set custom values by overwriting +stroke_width+ with the +class: "*:stroke-[10px]"+ argument.
    # @param options [Hash] additional HTML attributes passed to the SVG element, e.g. +class+ or +id+.
    def initialize(name,
                   theme: DEFAULT_ICON_THEME,
                   scheme: :none,
                   size: :md,
                   position: :leading,
                   stroke_width: DEFAULT_STROKE_WIDTH,
                   **options)
      @name = name.to_s.gsub("_", "-")
      @theme = fetch_or_fallback(ICON_THEME_OPTIONS, theme, DEFAULT_ICON_THEME)

      options.stringify_keys!
      layers = {}
      layers[:scheme] = scheme
      layers[:size] = size
      layers[:position] = position
      layers[:stroke_width] = stroke_width.to_s
      layers[:custom] = options.delete("class")
      options["class"] = styles(**layers)
      @options = options
    end

    def call
      render svg_component
    end

    private
    attr_reader :options, :theme, :name

    def svg_component
      @svg_component ||= Gustwave::Svg.new(icon_path, **options)
    end

    def icon_path
      File.join(ICON_PATH, theme.to_s, "#{name}.svg")
    end
  end
end
