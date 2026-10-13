# frozen_string_literal: true

module Gustwave
  module Form
    module RichText
      module Lexxy
        # Renders the toolbar button and dialog to add or remove a link.
        #
        # Lexxy's +lexxy-link-dropdown+ element opens and closes the dialog and
        # applies the link through the buttons' +value+ attributes.
        class LinkToggle < Gustwave::Component
          def initialize(disabled: false, **options)
            @disabled = disabled
            @options = options
          end

          private

          def trigger_options
            {
              disabled: @disabled,
              name: "link",
              "aria-haspopup": "dialog",
              "aria-expanded": "false",
              "data-dropdown-trigger": true,
              "data-hotkey": "cmd+k ctrl+k"
            }
          end
        end
      end
    end
  end
end
