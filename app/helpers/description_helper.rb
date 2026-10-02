module DescriptionHelper
  # Divides `text` into substrings based on a delimiter, returning an array
  # of these substrings.
  #
  # @param text [String, nil] The input string to be split into paragraphs.
  #   If `nil`, the method will return `nil`.
  # @param delimiter [String] The string used to separate the text into substrings.
  #   Defaults to a newline character ("\n").
  #
  # @example Splitting text by newline (default behavior)
  #   paragraphize("Hello\nWorld")
  #   # => ["Hello", "World"]
  #
  # @example Splitting text using a custom delimiter
  #   paragraphize("apple,banana,grape", delimiter: ",")
  #   # => ["apple", "banana", "grape"]
  #
  # @example Handling `nil` text
  #   paragraphize(nil)
  #   # => nil
  def paragraphize(text, delimiter: "\n")
    text&.split(delimiter)
  end

  # Joins the lines of `text` with `<br>` tags, escaping each line.
  #
  # Sanitized plain text (see RichTextSanitizer) is stored entity-encoded, so
  # entities are decoded first to avoid double-escaping. Escaping happens here
  # at render time, so the output is safe regardless of what was stored.
  #
  # @param text [String, nil] The text to render.
  #
  # @example
  #   simple_line_breaks("Tom &amp; Jerry\n<b>hi</b>")
  #   # => "Tom &amp; Jerry<br>&lt;b&gt;hi&lt;/b&gt;"
  def simple_line_breaks(text)
    safe_join(CGI.unescapeHTML(text.to_s).split("\n"), tag.br)
  end
end
