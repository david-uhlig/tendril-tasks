# frozen_string_literal: true

module Text
  module Highlight
    class GradientComponent < TendrilTasks::Component
      variant :color, default: :sky_to_emerald, values: {
        sky_to_emerald: "text-transparent bg-clip-text bg-linear-to-r to-emerald-600 from-sky-400"
      }

      def initialize(text = nil, highlight:, color: DEFAULT, **options)
        @text = text
        @highlight = highlight
        select_options(color:)
        @options = attributes_for(options)
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
    end
  end
end
