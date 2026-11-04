# frozen_string_literal: true

module Gustwave
  module SpeedDials
    # Use Trigger as the round button that opens a speed dial. It composes
    # Gustwave::Button and adds a plus icon that rotates on hover.
    #
    # @example
    #   render Gustwave::SpeedDials::Trigger.new("Open menu", icon: :plus, color: :dark)
    class Trigger < Gustwave::Component
      # The shape of the button. +:round+ renders a pill, +:square+ a rounded square.
      option :shape, default: :round, values: %i[round square]

      # @param text [String, nil] text to display to screen readers, rendered within +sr-only+ markup. If missing a localized version of "Open actions menu" is used.
      # @param icon [Symbol, nil] the icon of the button. Defaults to +:plus+.
      # @param shape [Symbol] the shape of the button, +:round+ or +:square+. Defaults to +:round+.
      # @param options [Hash] HTML attributes and button options, such as +theme+ and +color+, forwarded to Gustwave::Button. Block content replaces the icon.
      def initialize(text = nil, icon: :plus, shape: DEFAULT, **options)
        @text = text
        @icon = icon
        select_options(shape:)
        @round = option_value(:shape) == :round
        @theme = options.delete(:theme)
        @options = options
      end

      def before_render
        label = sr_only(@text.presence || t(".open_actions"))
        label = safe_join([ content, label ]) if content.present?

        attrs = configure_html_attributes(@options, class: "size-14 justify-center")
        @button = Gustwave::Button.for(@theme).new(label, pill: @round, size: :none, **attrs)
        return if content.present?

        @button.with_leading_visual_icon(@icon, class: "size-8 transition-transform group-hover:rotate-45")
      end

      def call
        render @button
      end
    end
  end
end
