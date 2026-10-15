# frozen_string_literal: true

module Gustwave
  class Svg < Gustwave::Component
    include InlineSvg::ActionView::Helpers

    def initialize(source = nil, **options)
      @source = source&.to_s
      @options = options
    end

    def call
      processed_svg
    end

    private
    attr_reader :options

    def processed_svg
      @svg ||= process_from_content || process_from_source
    end

    def process_from_content
      return unless content.present?

      with_html_attributes(content, options)
    end

    def process_from_source
      inline_svg_options, html_attributes = partition_options(options.deep_symbolize_keys)
      with_html_attributes(inline_svg_tag(@source, inline_svg_options), html_attributes)
    end

    # inline_svg drops options it has no transformation for, e.g. +role+ or
    # +tabindex+, and reads +aria+ as a flag to label the SVG by its title.
    # Splits off those HTML attributes, and an +aria+ hash, to set them on the
    # svg element directly.
    def partition_options(options)
      transformations = InlineSvg::TransformPipeline::Transformations.all_transformations.map(&:first)

      options
        .partition { |key, value| key.in?(transformations) && !(key == :aria && value.is_a?(Hash)) }
        .map(&:to_h)
    end

    # A labelled SVG isn't decorative, so it drops the +aria-hidden+ most
    # icon files carry, unless the caller sets +aria-hidden+ themselves.
    def with_html_attributes(svg_html, attributes)
      return svg_html if attributes.blank?

      doc = Nokogiri::HTML::DocumentFragment.parse(svg_html)
      svg = doc.at_css("svg")
      return svg_html unless svg

      attributes = normalize_html_attributes(**attributes)
      if attributes.key?(:"aria-label") || attributes.key?(:"aria-labelledby")
        svg.remove_attribute("aria-hidden") unless attributes.key?(:"aria-hidden")
      end
      attributes.each do |key, value|
        svg[key.to_s] = value.to_s
      end
      doc.to_html.html_safe
    end
  end
end
