# frozen_string_literal: true

# Fills in Lexxy editors in system tests.
#
# Action Text's +fill_in_rich_textarea+ finds the editor's contenteditable
# element, which holds the value in Trix but not in Lexxy. Lexxy keeps the
# value on its enclosing +lexxy-editor+ element.
module LexxySystemTestHelper
  # Locates a rich text area like Action Text's helper does and replaces its
  # content with the given HTML or plain text.
  #
  # Example:
  #   fill_in_rich_textarea "Beschreibung", with: "<p>Hello world!</p>"
  def fill_in_rich_textarea(locator = nil, with:, **)
    find(:rich_textarea, locator, **).execute_script(<<~JS, with.to_s)
      this.closest("lexxy-editor").value = arguments[0]
    JS
  end
  alias_method :fill_in_rich_text_area, :fill_in_rich_textarea
end
