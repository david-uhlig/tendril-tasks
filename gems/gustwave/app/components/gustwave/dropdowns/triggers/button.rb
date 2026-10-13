# frozen_string_literal: true

module Gustwave
  module Dropdowns
    module Triggers
      # Use the Button trigger to render a Gustwave::Button with a trailing
      # chevron icon in the direction of the menu's placement.
      class Button < Gustwave::Dropdowns::Triggers::Base
        delegate_missing_to :button_component

        # Translate the placement setting to an icon identifier showing to the
        # direction of the menu's placement
        PLACEMENT_ICON_MAPPINGS = {
          "auto": :chevron_down,
          "auto-start": :chevron_down,
          "auto-end": :chevron_down,
          "top": :chevron_up,
          "top-start": :chevron_up,
          "top-end": :chevron_up,
          "bottom": :chevron_down,
          "bottom-start": :chevron_down,
          "bottom-end": :chevron_down,
          "right": :chevron_right,
          "right-start": :chevron_right,
          "right-end": :chevron_right,
          "left": :chevron_left,
          "left-start": :chevron_left,
          "left-end": :chevron_left
        }.freeze

        # @param text [String, nil] the text to appear on the dropdown button. Takes precedent over block content.
        # @param icon [Symbol, nil] the icon identifier rendered as leading visual on the trigger button. Pass in +nil+ to not render an icon.
        # @param trailing_icon [Symbol, nil, false] the icon identifier rendered as trailing visual on the trigger button. Pass in +nil+ to automatically render a chevron icon pointing in the direction of +placement+. Pass in +false+ to not render a trailing icon.
        # @param options [Hash] additional options passed to Gustwave::Dropdowns::Triggers::Base and Gustwave::Button components.
        # @see Gustwave::Dropdowns::Triggers::Base
        def initialize(text = nil, icon: nil, trailing_icon: nil, **options)
          super(text, **options)
          @icon = icon
          @trailing_icon =
            if trailing_icon == false
              nil
            else
              (trailing_icon || icon_by_placement(options.fetch(:placement, :bottom)))
            end
        end

        def call
          render button_component do
            it.leading_icon(icon) if icon
            it.trailing_icon(trailing_icon) if trailing_icon
            text_or_content
          end
        end

        private
        attr_reader :icon, :trailing_icon

        def button_component
          @button_component ||= Gustwave::Button.new(**config)
        end

        def icon_by_placement(placement)
          PLACEMENT_ICON_MAPPINGS[placement]
        end
      end
    end
  end
end
