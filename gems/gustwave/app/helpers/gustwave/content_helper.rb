# frozen_string_literal: true

module Gustwave
  # Manage and render content and slots in components.
  module ContentHelper
    # Returns a span with the provided text as its content and the +sr-only+
    # class.
    #
    # If +text+ is not present, returns nil.
    #
    # @param text [String] the text to render.
    def sr_only(text)
      return unless text.present?

      tag.span text, class: "sr-only"
    end

    # Returns a safely joined string of rendered slots and appends the content
    # block.
    #
    # @param slots [Array<Object>] slots to render.
    # @param append_content [Boolean] whether to append the component's content (block) to the end of the slots. Defaults to true. To customize where and if the content block appears, pass it in the +slots+ array and set +append_content+ to false.
    # @return [String] a safely joined string of the slots and content (block).
    def slots_and_content(*slots, append_content: true)
      slots = slots.append(content) if append_content
      safe_join(slots.compact)
    end

    # Returns the given value if it is present, otherwise the component's content (block).
    #
    # @param text [Object, nil] the value to return if present: a String or any other renderable value, e.g. an html_safe span or a rich text object.
    # @return [Object] the given value, or the content (block) if the value is blank.
    def text_or_content(text)
      text.presence || content
    end
  end
end
