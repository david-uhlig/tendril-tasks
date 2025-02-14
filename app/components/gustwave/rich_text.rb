# frozen_string_literal: true

module Gustwave
  # Use to render rich text content
  class RichText < Gustwave::Component
    style :base,
          "*:hyphens-auto"

    def initialize(text = nil, **options)
      @text = text.to_s.html_safe

      options.symbolize_keys!
      options[:class] = styles(base: true,
                               custom: options.delete(:class))
      options[:lang] ||= I18n.default_locale
      @options = options
    end

    def call
      tag.div **@options do
        text_or_content
      end
    end
  end
end
