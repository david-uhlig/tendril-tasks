# frozen_string_literal: true

module Gustwave
  module SpeedDials
    # Use Trigger as the round button that opens a speed dial. It composes
    # Gustwave::Button and adds a plus icon that rotates on hover.
    #
    # The button's visual slots, such as +with_leading_visual_icon+, are
    # delegated to Gustwave::Button. A leading visual set through them replaces
    # the default +icon:+.
    #
    # @example
    #   render Gustwave::SpeedDials::Trigger.new("Open menu", icon: :plus, color: :dark)
    #
    # @example A custom icon through the slot
    #   render Gustwave::SpeedDials::Trigger.new("Open menu") do |trigger|
    #     trigger.with_leading_visual_icon :bars_3, theme: :solid, class: "size-8"
    #   end
    #
    # @status alpha
    class Trigger < Gustwave::Component
      delegate_missing_to :button_component

      # The shape of the button. +:round+ renders a pill, +:square+ a rounded square.
      option :shape, default: :round, values: %i[round square]

      # @param text [String, nil] text to display to screen readers, rendered within +sr-only+ markup. If missing a localized version of "Open actions menu" is used.
      # @param icon [Symbol, nil] the icon of the button. Defaults to +:plus+. Shorthand for a leading visual icon: a leading visual set through the button's slots replaces it.
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
        # Evaluates the block content, so visuals set in it are known here
        return if content.present? || !@icon || button_component.leading_visuals?

        button_component.with_leading_visual_icon(@icon, class: "size-8 transition-transform group-hover:rotate-45")
      end

      def call
        label = sr_only(@text.presence || t(".open_actions"))
        label = safe_join([ content, label ]) if content.present?

        render(button_component) { label }
      end

      private

      # Built on first use, so visual slots can be set before rendering. The
      # label is passed as block content at render time, as it depends on the
      # block content.
      def button_component
        @button_component ||= begin
          attrs = configure_html_attributes(@options, class: "size-14 justify-center")
          Gustwave::Button.for(@theme).new(pill: @round, size: :none, **attrs)
        end
      end
    end
  end
end
