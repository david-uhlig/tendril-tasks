# frozen_string_literal: true

module Gustwave
  # Use this component to render rich text content.
  class RichText < Gustwave::Component
    style :base, "*:hyphens-auto"

    # @param rich_text [ActionText::RichText, String] The rich text content to render. Strings will be converted to ActionText::Content.
    # @param options [Hash] Additional html attributes to pass to the enclosing div tag.
    def initialize(rich_text = nil, **options)
      @text = rich_text

      options.symbolize_keys!
      options[:class] = styles(
        base: true,
        custom: options.delete(:class)
      )
      options[:lang] ||= I18n.default_locale
      @options = options
    end

    def call
      tag.div **@options do
        render_rich_text(text_or_content)
      end
    end

    private

    def render_rich_text(html)
      if html.is_a?(ActionText::RichText)
        html.to_s
      else
        ActionText::Content.new(html.to_s).to_s
      end
    end
  end
end
