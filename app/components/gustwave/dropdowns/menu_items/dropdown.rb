# frozen_string_literal: true

module Gustwave
  module Dropdowns
    module MenuItems
      # Use Dropdown to render a Gustwave::Dropdown component submenu
      #
      # @see Gustwave::Dropdown
      class Dropdown < Gustwave::Dropdowns::MenuItems::Base
        delegate_missing_to :dropdown_component

        # @param text [String, nil] the text to appear on the dropdown button. Takes precedent over block content.
        # @param href [String] the URL to link to. Pass in +nil+ to not render a link.
        # @param icon [Symbol, nil] the icon identifier rendered as leading visual menu item. Pass in +nil+ to not render an icon.
        # @param trailing_icon [Symbol, nil, false] the icon identifier rendered as trailing visual on the trigger button. Pass in +nil+ to automatically render a chevron icon pointing in the direction of +placement+. Pass in +false+ to not render a trailing icon.
        # @param trigger_event [Symbol] the trigger event for the dropdown. Pass in :click (default) or :hover.
        # @param placement [Symbol] the placement of the dropdown. Options: +auto+, +auto-start+, +auto-end+, +top+, +top-start+, +top-end+, +bottom+, +bottom-start+, +bottom-end+, +right+, +right-start+, +right-end+, +left+, +left-start+, +left-end+. See: https://popper.js.org/docs/v2/constructors/#options
        #
        # @see Gustwave::Dropdown for more options
        def initialize(
          text = nil,
          href: nil,
          icon: nil,
          trailing_icon: nil,
          placement: :right,
          trigger_event: :hover,
          **options
        )
          kwargs = { href:, placement:, trigger_event:, icon:, trailing_icon: }
          @text = text
          @config = configure_component(
            options,
            **kwargs,
            tag: :a,
            role: :button,
            scheme: :none,
            size: :none,
            tabindex: "-1",
            class: styles(base: true),
          )
        end

        def call
          render dropdown_component do
            text_or_content(text: flex_grow(text))
          end
        end

        private
        attr_reader :config, :text

        def dropdown_component
          @dropdown_component ||= Gustwave::Dropdown.new(**config)
        end
      end
    end
  end
end
