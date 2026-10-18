# frozen_string_literal: true

module Gustwave
  class Svg < Gustwave::Component
    # A parsed SVG source file. Keeps the root +<svg>+ attributes and the
    # serialized markup of its children, so rendering a source doesn't parse
    # and serialize the file again.
    class Template
      CACHE = Concurrent::Map.new

      attr_reader :attributes, :inner_html

      class << self
        # Returns the template for a source file, or nil if the file is missing
        # or has no root svg. Templates are cached per source path, except when
        # reloading is enabled, so edited icons show without a restart.
        #
        # @param source [String] the path to the SVG file, e.g. +gustwave/icons/outline/close.svg+
        # @return [Template, nil]
        def for(source)
          return build(source) if Rails.application.config.enable_reloading

          CACHE[source] || build(source).tap { |template| CACHE[source] = template if template }
        end

        def clear_cache
          CACHE.clear
        end

        private

        def build(source)
          svg = Nokogiri::XML(InlineSvg.configuration.asset_file.named(source)).at_css("svg")
          new(svg) if svg
        rescue InlineSvg::AssetFile::FileNotFound
          nil
        end
      end

      # @param svg [Nokogiri::XML::Element] the root +<svg>+ element of the source
      def initialize(svg)
        namespaces = svg.namespace_definitions.to_h do |namespace|
          [ namespace.prefix ? "xmlns:#{namespace.prefix}" : "xmlns", namespace.href ]
        end
        svg_attributes = svg.attribute_nodes.to_h do |attribute|
          name = attribute.namespace ? "#{attribute.namespace.prefix}:#{attribute.name}" : attribute.name
          [ name, attribute.value ]
        end

        @attributes = namespaces.merge(svg_attributes).freeze
        @inner_html = svg.inner_html(encoding: "UTF-8").freeze
      end
    end
  end
end
