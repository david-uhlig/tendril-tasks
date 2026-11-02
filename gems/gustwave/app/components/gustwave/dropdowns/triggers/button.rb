# frozen_string_literal: true

module Gustwave
  module Dropdowns
    module Triggers
      # Use the Button trigger to render a Gustwave::Button with a chevron icon
      # in the direction of the menu's placement. The chevron trails the text,
      # except for a menu on the left, where it leads.
      class Button < Gustwave::Dropdowns::Triggers::Base
        delegate_missing_to :button_component

        # Translate the placement setting to an icon identifier showing to the
        # direction of the menu's placement
        PLACEMENT_ICON_MAPPINGS = {
          "auto": :chevron_down_compact,
          "auto-start": :chevron_down_compact,
          "auto-end": :chevron_down_compact,
          "top": :chevron_up_compact,
          "top-start": :chevron_up_compact,
          "top-end": :chevron_up_compact,
          "bottom": :chevron_down_compact,
          "bottom-start": :chevron_down_compact,
          "bottom-end": :chevron_down_compact,
          "right": :chevron_right_compact,
          "right-start": :chevron_right_compact,
          "right-end": :chevron_right_compact,
          "left": :chevron_left_compact,
          "left-start": :chevron_left_compact,
          "left-end": :chevron_left_compact
        }.freeze

        part :leading_chevron, "h-2.5 w-2.5 me-1.5"

        part :trailing_chevron, "h-2.5 w-2.5 ms-1.5"

        # @param text [String, nil] the text to appear on the dropdown button. Takes precedent over block content.
        # @param icon [Symbol, nil] the icon identifier rendered as leading visual on the trigger button. Pass in +nil+ to not render an icon.
        # @param trailing_icon [Symbol, nil, false] the icon identifier rendered as trailing visual on the trigger button. Pass in +nil+ to automatically render a chevron icon pointing in the direction of +placement+. Pass in +false+ to not render a trailing icon.
        # @param options [Hash] additional options passed to Gustwave::Dropdowns::Triggers::Base and Gustwave::Button components.
        # @see Gustwave::Dropdowns::Triggers::Base
        def initialize(text = nil, icon: nil, trailing_icon: nil, **options)
          super(text, **options)
          @icon = icon
          @trailing_icon = trailing_icon || nil
          @chevron = icon_by_placement(option_value(:placement)) if trailing_icon.nil?
        end

        def call
          render button_component do
            it.with_leading_visual_icon(icon, **icon_options) if icon
            it.with_leading_visual_icon(chevron, **chevron_options(:leading_chevron)) if chevron_leads?
            it.with_trailing_visual_icon(trailing_icon, **icon_options) if trailing_icon
            it.with_trailing_visual_icon(chevron, **chevron_options(:trailing_chevron)) if chevron && !chevron_leads?
            text_or_content(text)
          end
        end

        private
        attr_reader :icon, :trailing_icon, :chevron

        def icon_options
          {}
        end

        def chevron_options(part)
          { class: classes(part) }
        end

        # A leading icon keeps the leading position for itself
        def chevron_leads?
          chevron == :chevron_left_compact && icon.nil?
        end

        def button_component
          @button_component ||= Gustwave::Button.for(config[:theme]).new(**config.except(:theme))
        end

        def icon_by_placement(placement)
          PLACEMENT_ICON_MAPPINGS[placement]
        end
      end
    end
  end
end
