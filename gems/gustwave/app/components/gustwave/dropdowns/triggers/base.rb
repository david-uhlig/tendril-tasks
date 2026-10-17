# frozen_string_literal: true

module Gustwave
  module Dropdowns
    module Triggers
      # Use Base as a base class for building dropdown triggers
      #
      # This class is not meant to be used directly in the UI. It does not
      # render anything.
      #
      # Note: If you only want to convert an existing UI component
      # (e.g. Gustwave::Badge) into a dropdown trigger, you can use
      # Dropdowns::Triggers::Generic to wrap the component with trigger
      # behavior.
      #
      # Inherit from this class when your trigger needs extended behavior or
      # configuration.
      class Base < Gustwave::Component
        # Delay in milliseconds before showing the dropdown menu when the
        # trigger is activated
        DELAY_FLOWBITE_DEFAULT = 300
        DELAY_DEFAULT = DELAY_FLOWBITE_DEFAULT

        # How the trigger activates
        TRIGGER_FLOWBITE_DEFAULT = :click
        option :trigger_event, default: TRIGGER_FLOWBITE_DEFAULT, values: %i[click hover]

        # Where the dropdown menu appears relative to the trigger
        # See: https://popper.js.org/docs/v2/constructors/#options
        PLACEMENT_FLOWBITE_DEFAULT = :bottom
        option :placement, default: PLACEMENT_FLOWBITE_DEFAULT, values: %i[
          auto auto-start auto-end
          top top-start top-end
          bottom bottom-start bottom-end
          right right-start right-end
          left left-start left-end
        ]

        # Distance in pixels between the dropdown menu and the trigger in the
        # +placement+ main axis
        OFFSET_DISTANCE_FLOWBITE_DEFAULT = nil
        OFFSET_DISTANCE_DEFAULT = OFFSET_DISTANCE_FLOWBITE_DEFAULT

        # Distance in pixels between the dropdown menu and the trigger in the
        # +placement+ secondary axis
        OFFSET_SKIDDING_FLOWBITE_DEFAULT = nil
        OFFSET_SKIDDING_DEFAULT = OFFSET_SKIDDING_FLOWBITE_DEFAULT

        # @param text [String, nil] the text to appear on the trigger. Takes precedent over block content.
        # @param menu_id [String] the id of the target element.
        # @param trigger_event [Symbol] the trigger event for the dropdown. Pass in :click (default) or :hover.
        # @param delay [Integer] the delay in milliseconds before the dropdown is shown.
        # @param placement [Symbol] the placement of the dropdown. Options: +auto+, +auto-start+, +auto-end+, +top+, +top-start+, +top-end+, +bottom+, +bottom-start+, +bottom-end+, +right+, +right-start+, +right-end+, +left+, +left-start+, +left-end+. See: https://popper.js.org/docs/v2/constructors/#options
        # @param offset_distance [Integer] the distance in pixels between the target and the dropdown in the +placement+ main axis.
        # @param offset_skidding [Integer] the distance in pixels between the target and the dropdown in the +placement+ secondary axis.
        # @param options [Hash] additional options passed to the surrounding HTML element.
        def initialize(
          text = nil,
          menu_id:,
          trigger_event: DEFAULT,
          delay: DELAY_DEFAULT,
          placement: DEFAULT,
          offset_distance: OFFSET_DISTANCE_DEFAULT,
          offset_skidding: OFFSET_SKIDDING_DEFAULT,
          **options
        )
          @text = text
          @config = configure_trigger_options(
            menu_id: menu_id,
            trigger_event:,
            delay:,
            placement: (placement.to_s.tr("_", "-").to_sym unless placement.equal?(DEFAULT)),
            offset_distance:,
            offset_skidding:,
            **options
          )
        end

        private
        attr_reader :config, :text

        def configure_trigger_options(menu_id:, trigger_event:, delay:, placement:, offset_distance:, offset_skidding:, **options)
          select_options(trigger_event:, placement:)
          trigger = option_value(:trigger_event)
          placement = option_value(:placement)

          dropdown_config = {
            "dropdown-toggle": menu_id,
            "dropdown-trigger": (trigger.to_s unless trigger == TRIGGER_FLOWBITE_DEFAULT),
            "dropdown-delay": (delay unless delay == DELAY_FLOWBITE_DEFAULT),
            "dropdown-placement": (placement unless placement == PLACEMENT_FLOWBITE_DEFAULT),
            "dropdown-offset-distance": (offset_distance unless offset_distance == OFFSET_DISTANCE_FLOWBITE_DEFAULT),
            "dropdown-offset-skidding": (offset_skidding unless offset_skidding == OFFSET_SKIDDING_FLOWBITE_DEFAULT)
          }

          # The dropdown's own attributes win over the caller's, like Popover#trigger_options
          options = without_dropdown_attributes(options, dropdown_config.keys.map(&:to_s))
          configure_html_attributes(options, data: dropdown_config.compact, "aria-controls": menu_id)
        end

        # Drops +aria-controls+ and the +data_keys+ (e.g. +dropdown-toggle+),
        # flat or within an +aria+ or +data+ hash, off +options+. Keys match
        # as strings or symbols, with dashes or underscores.
        def without_dropdown_attributes(options, data_keys)
          options.each_with_object({}) do |(key, value), remaining|
            name = key.to_s.tr("_", "-")
            if name == "aria-controls" || data_keys.any? { name == "data-#{it}" }
              next
            elsif key.to_s == "data" && value.is_a?(Hash)
              data = value.reject { |data_key, _| data_keys.include?(data_key.to_s.tr("_", "-")) }
              remaining[key] = data if data.present?
            elsif key.to_s == "aria" && value.is_a?(Hash)
              aria = value.reject { |aria_key, _| aria_key.to_s == "controls" }
              remaining[key] = aria if aria.present?
            else
              remaining[key] = value
            end
          end
        end
      end
    end
  end
end
