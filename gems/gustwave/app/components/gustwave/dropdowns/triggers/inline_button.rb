# frozen_string_literal: true

module Gustwave
  module Dropdowns
    module Triggers
      # Use the InlineButton trigger to render a Gustwave::Buttons::Base with
      # inline styling so it looks like part of a text block.
      class InlineButton < Gustwave::Dropdowns::Triggers::Button
        style :base, "align-baseline gap-0"

        style :icon, "h-[1.5em] w-auto"

        # @param text [String, nil] the text to appear on the dropdown button. Takes precedent over block content.
        # @param options [Hash] additional options passed to Gustwave::Dropdowns::Triggers::Button and Gustwave::Buttons::Base components.
        # @see Gustwave::Dropdowns::Triggers::Button and Gustwave::Dropdowns::Triggers::Base
        def initialize(text = nil, **options)
          options = configure_component(
            options,
            class: styles(base: true),
            scheme: :none,
            size: :none
          )
          super(text, **options)
        end

        def call
          render button_component do
            it.leading_icon(icon, class: styles(icon: true)) if icon
            it.trailing_icon(trailing_icon, class: styles(icon: true)) if trailing_icon
            text_or_content
          end
        end

        private

        def button_component
          @button_component ||= Gustwave::Buttons::Base.new(**config)
        end
      end
    end
  end
end
