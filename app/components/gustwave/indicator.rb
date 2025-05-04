# frozen_string_literal: true

module Gustwave
  # Use Indicator to display status information
  #
  # Indicator supports three modes:
  # - By default, the indicator is rendered as a dot.
  # - When +text+ or block content is provided, the content is rendered within the dot. Works best for +size+ :md and larger. The dot is automatically stretched to a pill to fit the content.
  # - Use the +legend+ slot to render content to the right of the dot, making it look like a legend.
  #
  # === Position Indicator on other Components
  # Use the +position+ option to position the indicator on other components. Note: The underlying component must be +relative+ positioned.
  #
  #   <%= render Gustwave::Badge.new("Badge", class: "relative") do %>
  #     <%= render Gustwave::Indicator.new(position: :top_right, scheme: :blue) %>
  #   <% end %>
  class Indicator < Gustwave::Component
    style :base, "flex rounded-full aspect-square"

    style :text, "aspect-auto px-1 items-center justify-center text-white border-white"

    style :pulse, "animate-pulse"

    style :size,
          default: :auto,
          states: {
            none: "",
            auto: "h-[1em] min-w-[1em] text-[0.8em] font-semibold",
            xs: "h-2 min-w-2 text-xs font-normal",
            sm: "h-3 min-w-3 text-xs font-medium",
            md: "h-4 min-w-4 text-xs font-medium",
            lg: "h-6 min-w-6 text-sm font-semibold",
            xl: "h-8 min-w-8 text-md font-bold"
          }

    # TODO consistently add a :base style option to all components
    style :scheme,
          default: :gray,
          states: {
            none: "",
            gray: "bg-gray-200",
            dark: "bg-gray-900 dark:bg-gray-700",
            blue: "bg-blue-600",
            green: "bg-green-500",
            red: "bg-red-500",
            purple: "bg-purple-500",
            indigo: "bg-indigo-500",
            yellow: "bg-yellow-300",
            teal: "bg-teal-500",
            white: "bg-white"
          }

    style :position,
          default: :none,
          states: {
            none: "",
            top_left: "absolute -translate-y-1/2 -translate-x-1/2 right-auto top-0 left-0",
            top_center: "absolute -translate-y-1/2 translate-x-1/2 right-1/2",
            top_right: "absolute -translate-y-1/2 translate-x-1/2 left-auto top-0 right-0",
            middle_left: "absolute -translate-y-1/2 -translate-x-1/2 right-auto left-0 top-2/4",
            middle_center: "absolute -translate-y-1/2 -translate-x-1/2 top-2/4 left-1/2",
            middle_right: "absolute -translate-y-1/2 translate-x-1/2 left-auto right-0 top-2/4",
            bottom_left: "absolute translate-y-1/2 -translate-x-1/2 right-auto bottom-0 left-0",
            bottom_center: "absolute translate-y-1/2 translate-x-1/2 bottom-0 right-1/2",
            bottom_right: "absolute translate-y-1/2 translate-x-1/2 left-auto bottom-0 right-0"
          }

    renders_one :legend_slot, ->(text = nil, **options, &block) {
      @legend_config = configure_html_attributes(
        options,
        class: "flex items-center text-sm font-medium text-gray-900 dark:text-white gap-1.5"
      )
      @legend_content = text || block.call

      nil
    }
    alias legend with_legend_slot

    # @param text [String] the text to display in the indicator. Takes precedence over block content.
    # @param scheme [Symbol] the color scheme for the indicator. Pass in :none to define your own styles.
    # @param size [Symbol] the size of the indicator. Options: :none, :auto, :xs, :sm, :md, :lg, :xl. When chosing :auto, the indicator matches the line-height.
    # @param pulse [Boolean] whether to apply the pulse animation.
    # @param position [Symbol] positions the indicator on another component. The enclosing component must be +relative+ positioned.
    # @param options [Hash] additional options for the HTML tag, like class.
    def initialize(text = nil,
                   scheme: :gray,
                   size: :auto,
                   pulse: false,
                   position: :none,
                   **options)
      @text = text
      @kwargs = { scheme:, size:, pulse:, position: }
      @options = options
    end

    def before_render
      @kwargs.merge!(text: true) if text.present? || content.present?
      @config = configure_html_attributes(
        options,
        class: styles(
          base: (true unless @kwargs[:scheme] == :none),
          **kwargs
        )
      )
    end

    def call
      render_legend_wrapper do
        tag.span(**config) do
          text_or_content
        end
      end
    end

    private
    attr_reader :config, :legend_config, :legend_content, :options, :kwargs, :text

    def render_legend_wrapper(&block)
      return block.call unless legend_slot?

      tag.span(**legend_config) do
        safe_join([ block.call, legend_content ])
      end
    end
  end
end
