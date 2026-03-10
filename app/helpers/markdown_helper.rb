# frozen_string_literal: true

module MarkdownHelper
  class << self
    # Creates an anchor element of the given `name` to the `url`.
    #
    # @example
    #   MarkdownHelper.link_to("Example", "https://example.com")
    #   # => [Example](https://example.com)
    #
    # @param name [String] The link text.
    # @param url [String] The link URL.
    # @return [String]
    def link_to(name, url)
      "[#{name}](#{url})"
    end

    # Block quotes the given `text`.
    #
    # @example
    #   MarkdownHelper.quote("This is a quote\rover multiple lines.")
    #   # => "> This is a quote\n> over multiple lines."
    #
    # @param text [String] The text to quote.
    # @return [String] The quoted text or an empty string if the text is blank.
    def quote(text)
      return "" if text.blank?
      text.strip.split("\n").map { "> #{it}".strip }.join("\n")
    end

    # Italicizes the given `text`.
    #
    # @example
    #   MarkdownHelper.italic("example")
    #   # => "_example_"
    #
    # @example
    #   MarkdownHelper.italic("example", symbol: "*")
    #   # => "*example*"
    #
    # @param text [String] The text to italicize.
    # @param symbol [String] The wrapping symbol. One of: `_` and `*`.
    # @return [String] The italicized text or an empty string if the text is blank.
    def italic(text, symbol: "_", stripped: true)
      return "" if text.blank?
      wrap_each_line(text, symbol)
    end
    alias :italicize :italic

    # Bolds the given `text`.
    #
    # @example
    #   MarkdownHelper.bold("example")
    #   # => "**example**"
    #
    # @example
    #   MarkdownHelper.bold("example", symbol: "_")
    #   # => "__example__"
    #
    # @param text [String] The text to bold.
    # @param symbol [String] The wrapping symbol. One of: `*` and `_`.
    # @return [String] The bolded text or an empty string if the text is blank.
    def bold(text, symbol: "*")
      return "" if text.blank?
      wrap_each_line(text, symbol * 2)
    end

    private

    def wrap_each_line(text, symbol)
      text.split("\n").map { wrap(it, symbol) unless it.blank? }.join("\n")
    end

    def wrap(text, symbol)
      "#{symbol}#{text}#{symbol}"
    end
  end
end
