# frozen_string_literal: true

module TendrilTasks
  class Logo < TendrilTasks::Component
    DEFAULT_SIZE_RESIZE = :sm
    SIZE_RESIZE_MAPPINGS = {
      sm: 44,
      lg: 64
    }
    SIZE_RESIZE_OPTIONS = SIZE_RESIZE_MAPPINGS.keys

    base "[&_svg]:w-auto [&_img]:w-auto"

    variant :size, default: :sm, values: {
      sm: "[&_img]:h-8 sm:[&_img]:h-11 [&_svg]:h-8 sm:[&_svg]:h-11",
      lg: "[&_img]:h-12 sm:[&_img]:h-16 [&_svg]:h-12 sm:[&_svg]:h-16"
    }

    def initialize(id: "brand-logo", size: DEFAULT, **options)
      @site = Site.instance

      style_with(size:)
      @options = attributes_for(options)
      @options[:id] ||= id
      @resize_to = SIZE_RESIZE_MAPPINGS[fetch_or_fallback(SIZE_RESIZE_OPTIONS, style_value(:size), DEFAULT_SIZE_RESIZE)]
    end

    def call
      tag.div **@options do
        build_logo
      end
    end

    private

    def build_logo
      logo = @site.logo

      if logo_missing? || deprecated_svg_logo?
        return default_logo
      end

      image_tag rails_storage_proxy_path(
        logo.variant(resize_to_fit: [ nil, @resize_to ], format: :png)
      )
    end

    def logo_missing?
      !@site.logo.attached?
    end

    def deprecated_svg_logo?
      !logo_missing? && (
        @site.logo.content_type == "image/svg+xml" ||
        @site.logo.filename.to_s.downcase.end_with?(".svg")
      )
    end

    def default_logo
      image_tag("brand/logo.svg")
    end
  end
end
