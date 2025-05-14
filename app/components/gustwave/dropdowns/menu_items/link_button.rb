# frozen_string_literal: true

module Gustwave
  module Dropdowns
    module MenuItems
      # Use LinkButton to render a Gustwave::Button element as an anchor
      #
      # Takes the same arguments as Gustwave::Button
      #
      # Note: When providing block content, you must apply grow (flex)
      # yourself. When using the +text+ argument, the text content automatically
      # grows so that the trailing icon is right aligned.
      class LinkButton < Gustwave::Dropdowns::MenuItems::Base
        delegate_missing_to :button_component

        style :leading_icon, "h-[1.5em]"
        style :trailing_icon, "h-[1.5em]"

        # @param text [String, nil] the text to appear on the dropdown button. Takes precedent over block content.
        # @param href [String] the URL to link to.
        # @param icon [Symbol, nil] the icon identifier rendered as leading visual menu item. Pass in +nil+ to not render an icon.
        # @param trailing_icon [Symbol, nil] the icon identifier rendered as trailing visual on the trigger button. Pass in +nil+ to not render an icon.
        # @param options [Hash] additional options passed to the Gustwave::Button component.
        def initialize(
          text = nil,
          href: "#",
          icon: nil,
          trailing_icon: nil,
          **options
        )
          kwargs = { href: }
          @text = text
          @icon = icon
          @trailing_icon = trailing_icon
          @config = configure_component(
            options,
            **kwargs,
            scheme: :none,
            size: :none,
            tag: :a,
            tabindex: "-1",
            class: styles(base: true),
            )
        end

        def call
          render button_component do
            it.leading_icon(icon, class: styles(leading_icon: true)) if icon
            it.trailing_icon(trailing_icon, class: styles(trailing_icon: true)) if trailing_icon
            text_or_content(text: flex_grow(text))
          end
        end

        private
        attr_reader :config, :icon, :trailing_icon, :text

        def button_component
          @button_component ||= Gustwave::Button.new(**config)
        end
      end
    end
  end
end
