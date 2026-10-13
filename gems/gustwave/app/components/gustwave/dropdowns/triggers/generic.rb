# frozen_string_literal: true

module Gustwave
  module Dropdowns
    module Triggers
      # Use the Generic trigger to convert any HTML element into a dropdown
      # trigger, including components
      #
      # Wraps the supplied content in an HTML element (default: +div+) that acts
      # as the trigger.
      class Generic < Gustwave::Dropdowns::Triggers::Base
        style :base, "inline-flex cursor-pointer"

        # @param text [String, nil] the text to appear on the generic dropdown. Takes precedent over block content.
        # @param tag [Symbol] HTML tag used to wrap the generic dropdown component in.
        # @param options [Hash] additional options passed to Gustwave::Dropdowns::Triggers::Base component and the wrapping `content_tag`.
        # @see Gustwave::Dropdowns::Triggers::Base
        def initialize(text = nil, tag: :div, **options)
          options = configure_component(options, class: styles(base: true))
          super(text, **options)
          @tag = tag
        end

        def call
          content_tag(tag, config) do
            text_or_content
          end
        end

        private
        attr_reader :tag
      end
    end
  end
end
