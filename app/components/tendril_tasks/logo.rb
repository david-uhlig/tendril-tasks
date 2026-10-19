# frozen_string_literal: true

module TendrilTasks
  class Logo < TendrilTasks::Component
    base "[&_svg]:w-auto [&_img]:w-auto"

    variant :size, default: :sm, values: {
      sm: "[&_img]:h-8 sm:[&_img]:h-11 [&_svg]:h-8 sm:[&_svg]:h-11",
      lg: "[&_img]:h-12 sm:[&_img]:h-16 [&_svg]:h-12 sm:[&_svg]:h-16"
    }

    # The height in pixels to resize an uploaded logo to, covering the largest
    # rendered height per size. Without size classes, it renders like :sm.
    derive :resize_height, from: :size, values: {
      none: 44,
      sm: 44,
      lg: 64
    }

    def initialize(id: "brand-logo", size: DEFAULT, **options)
      @site = Site.instance

      select_options(size:)
      @options = attributes_for(options)
      @options[:id] ||= id
      @resize_to = derived_value(:resize_height)
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
      ), alt: @site.navigation_label
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
      image_tag("brand/logo.svg", alt: @site.navigation_label)
    end
  end
end
