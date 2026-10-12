# frozen_string_literal: true

module Text
  module Highlight
    class GradientComponent < TendrilTasks::Component
      DEFAULT_SCHEME = :sky_to_emerald
      SCHEME_MAPPINGS = {
        none: "",
        sky_to_emerald: "text-transparent bg-clip-text bg-linear-to-r to-emerald-600 from-sky-400"
      }
      SCHEME_OPTIONS = SCHEME_MAPPINGS.keys

      def initialize(text = nil, highlight:, scheme: DEFAULT_SCHEME, **options)
        @text = text
        @highlight = highlight
        @options = build_options(options, scheme)
      end

      # Escapes the text, as admins can enter it, e.g. the headline on the home
      # page. Shows the text as is without a highlight.
      def call
        text = ERB::Util.html_escape(@text || content).to_str
        return text.html_safe if @highlight.blank?

        text.gsub(ERB::Util.html_escape(@highlight).to_str) do |match|
          tag.span match.html_safe, **@options
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
