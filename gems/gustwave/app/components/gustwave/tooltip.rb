# frozen_string_literal: true

module Gustwave
  # A short text that appears next to a trigger element, using Flowbite's
  # tooltip. Spread +trigger_options+ into the trigger, which also points
  # +aria-describedby+ at the tooltip. Pass the trigger's own
  # +aria-describedby+ to +trigger_options+ to keep it.
  #
  # Render the tooltip anywhere on the page; it doesn't need to follow its
  # trigger. The arrow is drawn by its +::before+ only: the +::after+ of
  # Flowbite's arrow would cover the border of the light tooltip's arrow, which
  # is set through the tooltip's placement, not through its position next to
  # the trigger.
  #
  # The +tooltip+ class that Flowbite's CSS positions the arrow by is always
  # set. With <tt>color: :none</tt> callers bring the remaining classes
  # themselves, including +invisible+, +opacity-0+ and any transition, which
  # Flowbite's script toggles.
  #
  # Animate the fade-in with a duration class, e.g. <tt>class: "duration-500"</tt>.
  #
  # @example
  #   <% tooltip = Gustwave::Tooltip.new("Tooltip content", color: :light, class: "duration-500") %>
  #   <%= render Gustwave::Button.new("Hover me", **tooltip.trigger_options(placement: :bottom)) %>
  #   <%= render tooltip %>
  class Tooltip < Gustwave::Component
    # See: https://popper.js.org/docs/v2/constructors/#options
    option :placement, default: :top, values: %i[
      auto auto-start auto-end
      top top-start top-end
      bottom bottom-start bottom-end
      right right-start right-end
      left left-start left-end
    ]

    option :trigger, default: :hover, values: %i[hover click]

    base "absolute z-10 invisible inline-block px-3 py-2 text-sm font-medium transition-opacity duration-300 rounded-lg shadow-xs opacity-0"
    part :arrow, "tooltip-arrow after:hidden"
    unstyled color: :none

    variant :color, default: :dark, values: {
      dark: "text-white bg-gray-900 dark:bg-gray-700",
      light: {
        root: "text-gray-900 bg-white border border-gray-200",
        arrow: "before:border-gray-200 " \
               "[[data-popper-placement^=top]>&]:before:border-b [[data-popper-placement^=top]>&]:before:border-r " \
               "[[data-popper-placement^=right]>&]:before:border-b [[data-popper-placement^=right]>&]:before:border-l " \
               "[[data-popper-placement^=bottom]>&]:before:border-t [[data-popper-placement^=bottom]>&]:before:border-l " \
               "[[data-popper-placement^=left]>&]:before:border-t [[data-popper-placement^=left]>&]:before:border-r"
      }
    }

    def initialize(text = nil, id: nil, color: DEFAULT, arrow: true, **options)
      @id = id || generate_random_id(prefix: "tooltip")
      @arrow = ActiveModel::Type::Boolean.new.cast(arrow) != false
      @text = text

      select_options(color:)
      options = options.symbolize_keys
      options[:id] = @id
      options[:role] ||= "tooltip"
      options[:class] = [ "tooltip", options[:class] ].compact
      @options = attributes_for(options)
    end

    def call
      tag.div **@options do
        concat text_or_content(text)
        concat popper_arrow
      end
    end

    # Returns the HTML attributes that attach the trigger to the tooltip.
    #
    # Pass the trigger's own +aria-describedby+ in +attributes+ to keep it: it
    # is joined with the tooltip's id. Given to the trigger next to
    # +trigger_options+, it is lost. The other +attributes+ are returned as
    # they are.
    #
    #   <%= link_to "Docs", docs_path, **tooltip.trigger_options("aria-describedby": "help", class: "underline") %>
    #
    # @param attributes [Hash] the trigger's own HTML attributes.
    def trigger_options(placement: DEFAULT, trigger: DEFAULT, **attributes)
      described_by, options = extract_described_by(attributes)
      options["data-tooltip-target"] = @id
      options["data-tooltip-placement"] = option_value(:placement, placement:)
      options["data-tooltip-trigger"] = option_value(:trigger, trigger:)
      options["data-tooltip-style"] = "light" if option_value(:color) == :light
      options["aria-describedby"] = [ *described_by, @id ].uniq.join(" ")
      options
    end

    private

    attr_reader :text

    # Splits the ids of +aria-describedby+, flat or within an +aria+ hash, off
    # +attributes+.
    def extract_described_by(attributes)
      ids = []
      options = attributes.each_with_object({}) do |(key, value), remaining|
        if key.to_s == "aria-describedby"
          ids << value
        elsif key.to_s == "aria" && value.is_a?(Hash)
          aria = value.reject { |aria_key, _| aria_key.to_s == "describedby" }
          ids << value.find { |aria_key, _| aria_key.to_s == "describedby" }&.last
          remaining[key] = aria if aria.present?
        else
          remaining[key] = value
        end
      end
      [ ids.flat_map { Array(it).flat_map { |id| id.to_s.split } }, options ]
    end

    def popper_arrow
      return nil unless @arrow
      tag.div class: classes(:arrow), "data-popper-arrow": true
    end
  end
end
