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

    # Returns the provided text argument, instance variable @text, or the component's content (block).
    #
    # If `eval_content` is true, the content (block) is evaluated to ensure that any defined slots are rendered.
    #
    # @param text [String, nil] the text to return if provided. Takes precedence over +@text+ and the content (block).
    # @param eval_content [Boolean] whether to evaluate the content (block) to ensure slots are rendered. Defaults to true.
    # @return [String] The resolved text or content. The precedence is +text+ > +@text+ > content (block).
    def text_or_content(text: nil, eval_content: true)
      # Evaluate content to ensure slots are rendered
      content if eval_content

      text.presence || @text.presence || content
    end
  end
end
