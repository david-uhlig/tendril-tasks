# frozen_string_literal: true

module Gustwave
  class Icon < Gustwave::Component
    ICON_PATH = File.join("icons").freeze

    DEFAULT_ICON_THEME = :outline
    ICON_THEME_OPTIONS = [ :outline, :solid ].freeze

    SVG_STROKE_WIDTH = 1.5
    DEFAULT_STROKE_WIDTH = SVG_STROKE_WIDTH

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
            "4": "*:stroke-[4px]"
          }

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

    style :position,
          default: :leading,
          states: {
            leading: "me-1.5",
            trailing: "ms-1.5",
            inline: "mx-1.5",
            standalone: ""
          }

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
