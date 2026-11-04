# frozen_string_literal: true

module Gustwave
  class Popover < Gustwave::Component
    # See: https://popper.js.org/docs/v2/constructors/#options
    option :placement, default: :top, values: %i[
      auto auto-start auto-end
      top top-start top-end
      bottom bottom-start bottom-end
      right right-start right-end
      left left-start left-end
    ]

    option :trigger, default: :hover, values: %i[hover click]

    base "absolute z-10 invisible inline-block text-sm text-gray-500 transition-opacity duration-300 bg-white border border-gray-200 rounded-lg shadow-xs opacity-0 dark:text-gray-400 dark:border-gray-600 dark:bg-gray-800"

    def initialize(text = nil, id: nil, arrow: true, **options)
      @id = id || generate_random_id(prefix: "popover")
      @arrow = ActiveModel::Type::Boolean.new.cast(arrow) != false
      @text = text

      options.symbolize_keys!
      options[:id] = @id
      options[:"data-popover"] = true
      options[:role] ||= "tooltip"
      @options = attributes_for(options)
    end

    def call
      tag.div **@options do
        concat text_or_content(text)
        concat popper_arrow
      end
    end

    # Returns the HTML attributes that attach the trigger to the popover.
    #
    # The popover's own attributes take precedence over any caller attribute
    # with the same name, so the trigger never ends up with duplicate keys.
    # A hover popover describes its trigger, so the trigger's +aria-describedby+
    # points at the popover, joined with the trigger's own. A click popover is
    # opened by its trigger, so the trigger's +aria-controls+ points at the
    # popover, replacing the trigger's own. The trigger's other +attributes+
    # are returned as they are.
    #
    #   <%= link_to "Docs", docs_path, **popover.trigger_options(class: "underline", data: { controller: "x" }) %>
    #
    # @param attributes [Hash] the trigger's own HTML attributes.
    def trigger_options(placement: DEFAULT,
                        trigger: DEFAULT,
                        offset: nil,
                        **attributes)
      popover_keys = %w[data-popover-target data-popover-placement data-popover-trigger data-popover-offset]
      options = attributes.reject { |key, _| popover_keys.include?(key.to_s) }
      event = option_value(:trigger, trigger:)
      options["data-popover-target"] = @id
      options["data-popover-placement"] = option_value(:placement, placement:)
      options["data-popover-trigger"] = event
      options["data-popover-offset"] = offset if offset.present?
      if event == :hover
        described_by, options = extract_described_by(options)
        options["aria-describedby"] = [ *described_by, @id ].uniq.join(" ")
      else
        options = without_controls(options)
        options["aria-controls"] = @id
      end
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
      tag.div "data-popper-arrow": true
    end
  end
end
