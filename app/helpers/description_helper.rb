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
end
