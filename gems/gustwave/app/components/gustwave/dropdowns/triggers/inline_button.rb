# frozen_string_literal: true

module Gustwave
  module Dropdowns
    module Triggers
      # Use the InlineButton trigger to render a Gustwave::Buttons::Base with
      # inline styling so it looks like part of a text block.
      class InlineButton < Gustwave::Dropdowns::Triggers::Button
        base "align-baseline gap-0"

        part :icon, "h-[1.5em] w-auto"

        part :leading_chevron, "h-2.5 w-2.5 me-3"

        part :trailing_chevron, "h-2.5 w-2.5 ms-3"

        # @param text [String, nil] the text to appear on the dropdown button. Takes precedent over block content.
        # @param options [Hash] additional options passed to Gustwave::Dropdowns::Triggers::Button and Gustwave::Buttons::Base components.
        # @see Gustwave::Dropdowns::Triggers::Button and Gustwave::Dropdowns::Triggers::Base
        def initialize(text = nil, **options)
          options = { color: :none, size: :none }.merge(attributes_for(options))
          super(text, **options)
        end

        private

        def icon_options
          { class: classes(:icon) }
        end

        def button_component
          @button_component ||= Gustwave::Buttons::Base.new(**config)
        end
      end
    end
  end
end
