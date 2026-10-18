# frozen_string_literal: true

module Gustwave
  class Svg < Gustwave::Component
    include InlineSvg::ActionView::Helpers

    # inline_svg's title, desc and nocomment transformations, and its aria flag,
    # change the markup itself, so those renders still go through inline_svg.
    INLINE_MARKUP_OPTIONS = %i[title desc nocomment].freeze

    # Root attribute names of inline_svg's transformations, where they differ from the option name.
    INLINE_ATTRIBUTE_NAMES = {
      id: "id",
      width: "width",
      height: "height",
      aria_hidden: "aria-hidden",
      view_box: "viewBox",
      preserve_aspect_ratio: "preserveAspectRatio"
    }.freeze

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
      source_options = options.deep_symbolize_keys
      template = Template.for(@source) if template_compatible?(source_options)
      return render_from_template(template, source_options) if template

      inline_svg_options, html_attributes = partition_options(source_options)
      with_html_attributes(inline_svg_tag(@source, inline_svg_options), html_attributes)
    end

    def template_compatible?(source_options)
      return false if @source.blank? || InlineSvg::TransformPipeline::Transformations.custom_transformations.any?
      return false if source_options.keys.intersect?(INLINE_MARKUP_OPTIONS)

      !(source_options[:aria] && !source_options[:aria].is_a?(Hash))
    end

    # Renders the cached root attributes with the options applied, without
    # parsing the markup again. Follows the rules of inline_svg's
    # transformations and of #with_html_attributes.
    def render_from_template(template, source_options)
      inline_svg_options, html_attributes = partition_options(source_options)
      attributes = template.attributes.dup
      inline_svg_options.each { |key, value| apply_inline_svg_option(attributes, key, value) if value }

      html_attributes = normalize_html_attributes(**html_attributes).to_h { |key, value| [ key.to_s, value.to_s ] }
      labelled = html_attributes.key?("aria-label") || html_attributes.key?("aria-labelledby")
      caller_hidden = inline_svg_options.key?(:aria_hidden) || html_attributes.key?("aria-hidden")
      attributes.delete("aria-hidden") if labelled && !caller_hidden

      attributes.merge!(html_attributes)
      content_tag(:svg, template.inner_html.html_safe, attributes)
    end

    def apply_inline_svg_option(attributes, key, value)
      case key
      when :class
        attributes["class"] = (attributes["class"].to_s.split(" ") << value.to_s).join(" ")
      when :style
        attributes["style"] = (attributes["style"].to_s.split(";") << value.to_s).join(";")
      when :data
        value.each { |name, data| attributes["data-#{name.to_s.tr("_", "-")}"] = data.to_s } if value.is_a?(Hash)
      when :size
        width, height = value.to_s.split("*").map(&:strip)
        attributes["width"] = width.to_s
        attributes["height"] = (height || width).to_s
      else
        attributes[INLINE_ATTRIBUTE_NAMES.fetch(key)] = value.to_s
      end
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
