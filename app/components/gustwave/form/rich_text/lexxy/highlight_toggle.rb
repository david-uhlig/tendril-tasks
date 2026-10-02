# frozen_string_literal: true

module Gustwave
  module Form
    module RichText
      module Lexxy
        # Renders the toolbar button and menu to highlight text in color.
        #
        # Lexxy's +lexxy-highlight-dropdown+ element fills the menu with the
        # configured colors and applies them to the selected text.
        class HighlightToggle < Gustwave::Component
          def initialize(disabled: false, **options)
            @disabled = disabled
            @options = options
          end

          private

          def trigger_options
            {
              disabled: @disabled,
              name: "highlight",
              "aria-haspopup": "menu",
              "aria-expanded": "false",
              "data-dropdown-trigger": true
            }
          end
        end
      end
    end
  end
end
