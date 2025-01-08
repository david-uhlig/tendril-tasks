# frozen_string_literal: true

module Gustwave
  class Svg < Gustwave::Component
    def initialize(source = nil, **options)
      @source = source&.to_s
      @options = options
    end

    def call
      processed_svg
    end

    private

    def processed_svg
      @svg ||= process_from_content || process_from_source
    end

    def process_from_content
      return unless content.present?

      options = @options.deep_stringify_keys

      svg_html = content
      doc = Nokogiri::HTML::DocumentFragment.parse(svg_html)
      svg = doc.at_css("svg")
      options.each do |key, value|
        svg[key] = value
      end
      doc.to_html.html_safe
    end

    def process_from_source
      options = @options.deep_symbolize_keys
      inline_svg_tag(@source, options)
    end
  end
end
