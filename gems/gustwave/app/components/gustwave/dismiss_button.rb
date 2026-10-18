# frozen_string_literal: true

module Gustwave
  # Use DismissButton to render a button that dismisses the target element.
  #
  # The button is an Inline button with an "X" icon by default. It closes the
  # element with the HTML id attribute that matches the target parameter. The
  # target element doesn't require any additional markup.
  #
  # @example
  #   render Gustwave::DismissButton.new("my-modal", "Close modal", color: :dark, size: :lg)
  class DismissButton < Gustwave::Component
    # @param target [String] the id of the element to dismiss, without +#+
    # @param text [String, nil] text to display to screen readers, rendered within +sr-only+ markup. If missing block content is rendered without +sr-only+ markup. If both are missing a localized version of "Dismiss" is used.
    # @param theme [Symbol] the Gustwave::Button theme of the button. Defaults to :inline.
    # @param icon [Symbol, nil] the icon of the button. Defaults to +:close+. Use +nil+ for no icon.
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
      label = @text.presence || t(".dismiss")
      a11y_text = sr_only(@text) || content.presence || sr_only(t(".dismiss"))
      attrs = configure_html_attributes(@options, data: { dismiss_target: "##{@target}" }, aria: { label: })

      @button = Gustwave::Button.for(@theme).new(a11y_text, **attrs)
      @button.with_leading_visual_icon(@icon, stroke_width: 2, **@icon_options) if @icon
    end

    def call
      render @button
    end
  end
end
