module Gustwave
  class ClipboardPreview < ViewComponent::Preview
    # A text input with a button beside it. The button copies the value and
    # shows "Copied!" for a moment.
    def default
      render_with_template
    end

    # An input with a copy icon inside its right edge. A tooltip next to the
    # icon says "Copy to clipboard", and changes to "Copied!" after the copy.
    def input_with_copy_button
      render_with_template
    end

    # An input with a copy button that has a text label. The label changes to
    # "Copied" after the copy, in blue.
    def copy_button_with_text
      render_with_template
    end

    # An input group: a URL label on the left, the input, and a copy button on
    # the right. The button has a tooltip, "Copy link", and the helper text
    # below it.
    def input_group
      render_with_template
    end

    # A URL shortener: a "Generate" button, the shortened URL in an input, and
    # a copy button with a "Copy link" tooltip.
    def url_shortener
      render_with_template
    end

    # A code block with a "Copy code" button in its corner. The button copies
    # the code as plain text, with its HTML entities decoded.
    def source_code_block
      render_with_template
    end

    # A card with three inputs for keys and IDs, each with its own copy icon
    # and tooltip, and two buttons to move on.
    def api_keys_card
      render_with_template
    end

    # An address card with a copy icon in its corner. The icon copies the
    # contact details as text.
    def contact_details
      render_with_template
    end

    # A "Share course" button that opens a modal. The modal has the course link
    # in an input with a copy icon and a tooltip, and a Close button.
    def modal
      render_with_template
    end
  end
end
