# frozen_string_literal: true

module Gustwave
  class Component < ViewComponent::Base
    include Primer::FetchOrFallbackHelper
    include Gustwave::Styleable
    include Gustwave::Themeable
    include TailwindHelper

    def normalize_keys(options)
      normalized_options = {}

      options.each do |key, value|
        normalized_key = key.to_s.downcase.gsub("_", "-")

        if %w[aria data].include?(key) && value.is_a?(Hash)
          value.each do |sub_key, sub_value|
            normalized_options["#{key}-#{sub_key.to_s.downcase}"] = sub_value
          end
        else
          normalized_options[normalized_key] = value
        end
      end

      normalized_options.deep_symbolize_keys!
    end

    def lightswitch_cast(value)
      return value if [ :on, :off ].include?(value)
      return value.to_sym if %w[on off].include?(value)
      fetch_or_fallback_boolean(value, false)
    end

    def random_id(prefix: nil, postfix: nil, length: 5)
      [ prefix, SecureRandom.alphanumeric(length).downcase, postfix ]
        .compact
        .join("-")
    end

    # Returns the provided text, @text or the component's content (block).
    # If `eval_content` is true, evaluates the content to ensure slots are
    # rendered.
    #
    # @param text [String, nil] the text to return if provided
    # @param eval_content [Boolean] whether to evaluate the content (block)
    # @return [String] text takes precedent over @text, over the content (block)
    def text_or_content(text: nil, eval_content: true)
      # We must eval content when the component defines a slot, otherwise the
      # slots are not rendered.
      content if eval_content

      text.presence || @text.presence || content
    end
  end
end
