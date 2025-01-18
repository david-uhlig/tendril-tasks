# frozen_string_literal: true

module Gustwave
  class Popover < Gustwave::Component
    # See: https://popper.js.org/docs/v2/constructors/#options
    PLACEMENT_DEFAULT = :top
    PLACEMENT_OPTIONS = %i[
      auto auto-start auto-end
      top top-start top-end
      bottom bottom-start bottom-end
      right right-start right-end
      left left-start left-end].freeze

    TRIGGER_DEFAULT = :hover
    TRIGGER_OPTIONS = %i[hover click].freeze

    style :base,
          "absolute z-10 invisible inline-block text-sm text-gray-500 transition-opacity duration-300 bg-white border border-gray-200 rounded-lg shadow-sm opacity-0 dark:text-gray-400 dark:border-gray-600 dark:bg-gray-800"

    def initialize(text = nil, id: nil, arrow: true, **options)
      @id = id || random_id(prefix: "popover")
      @arrow = fetch_or_fallback_boolean(arrow, true)
      @text = text

      options.symbolize_keys!
      options[:id] = @id
      options[:"data-popover"] = true
      options[:role] ||= "tooltip"
      options[:class] = styles(base: true, custom: options.delete(:class))
      @options = options
    end

    def call
      tag.div **@options do
        concat text_or_content
        concat popper_arrow
      end
    end

    def trigger_options(placement: PLACEMENT_DEFAULT,
                        trigger: TRIGGER_DEFAULT,
                        offset: nil)
      options = {}
      options["data-popover-target"] = @id
      options["data-popover-placement"] = fetch_or_fallback(
        PLACEMENT_OPTIONS, placement, PLACEMENT_DEFAULT
      )
      options["data-popover-trigger"] = fetch_or_fallback(
        TRIGGER_OPTIONS, trigger, TRIGGER_DEFAULT)
      options["data-popover-offset"] = offset if offset.present?
      options
    end

    private

    def popper_arrow
      return nil unless @arrow
      tag.div "data-popper-arrow": true
    end
  end
end
