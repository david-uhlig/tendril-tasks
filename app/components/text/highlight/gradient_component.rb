# frozen_string_literal: true

module Text
  module Highlight
    class GradientComponent < ApplicationComponent
      DEFAULT_SCHEME = :sky_to_emerald
      SCHEME_MAPPINGS = {
        none: "",
        sky_to_emerald: "text-transparent bg-clip-text bg-gradient-to-r to-emerald-600 from-sky-400"
      }
      SCHEME_OPTIONS = SCHEME_MAPPINGS.keys

      def initialize(text = nil, highlight:, scheme: DEFAULT_SCHEME, **options)
        @text = text
        @highlight = highlight
        @options = build_options(options, scheme)
      end

      def call
        text = @text || content
        text.gsub(@highlight) do |match|
          tag.span match, **@options
        end.html_safe
      end

      private

      def build_options(options, scheme)
        options.deep_symbolize_keys!
        options[:class] = class_merge(
          SCHEME_MAPPINGS[fetch_or_fallback(SCHEME_OPTIONS, scheme, DEFAULT_SCHEME)],
          options.delete(:class)
        )
        options
      end
    end
  end
end
