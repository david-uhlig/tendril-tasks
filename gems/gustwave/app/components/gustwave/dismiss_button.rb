# frozen_string_literal: true

module Gustwave
  # Use DismissButton to render a button that dismisses the target element.
  #
  # The button is an Inline button with an "X" icon by default. It closes the
  # element with the HTML id attribute that matches the target parameter. The
  # target element doesn't require any additional markup.
  #
  # The button's visual slots, such as +with_leading_visual_icon+, are
  # delegated to Gustwave::Button. A leading visual set through them replaces
  # the default +icon:+.
  #
  # @example
  #   render Gustwave::DismissButton.new("my-modal", "Close modal", color: :dark, size: :lg)
  #
  # @example A custom icon through the slot
  #   render Gustwave::DismissButton.new("my-modal") do |button|
  #     button.with_leading_visual_icon :x_mark, theme: :solid
  #   end
  #
  # @status alpha
  class DismissButton < Gustwave::Component
    delegate_missing_to :button_component

    # @param target [String] the id of the element to dismiss, without +#+
    # @param text [String, nil] text to display to screen readers, rendered within +sr-only+ markup. If missing block content is rendered without +sr-only+ markup. If both are missing a localized version of "Dismiss" is used.
    # @param theme [Symbol] the Gustwave::Button theme of the button. Defaults to :inline.
    # @param icon [Symbol, nil] the icon of the button. Defaults to +:close+. Use +nil+ for no icon. Shorthand for a leading visual icon: a leading visual set through the button's slots replaces it.
    # @param icon_options [Hash] options for the icon, e.g. its +class+.
    # @param options [Hash] HTML attributes and button options, such as +color+ and +size+, forwarded to the button. Its +data+ and +aria+ hashes merge with the defaults.
    def initialize(target,
                   text = nil,
                   theme: :inline,
                   icon: :close,
                   icon_options: {},
                   **options)
      @target = target
      @text = text
      @theme = theme
      @icon = icon
      @icon_options = icon_options
      @options = options
    end

    def before_render
      # Evaluates the block content, so visuals set in it are known here
      content
      return if !@icon || button_component.leading_visuals?

      button_component.with_leading_visual_icon(@icon, stroke_width: 2, **@icon_options)
    end

    def call
      render(button_component) { a11y_text }
    end

    private

    # Built on first use, so visual slots can be set before rendering. The
    # label and attributes come from the initializer, and the screen reader
    # text is passed as block content at render time. The class-level
    # translate works before rendering, unlike the instance's t.
    def button_component
      @button_component ||= begin
        label = @text.presence || self.class.translate(".dismiss")
        attrs = configure_html_attributes(@options, data: { dismiss_target: "##{@target}" }, aria: { label: })
        Gustwave::Button.for(@theme).new(**attrs)
      end
    end

    def a11y_text
      sr_only(@text) || content.presence || sr_only(t(".dismiss"))
    end
  end
end
