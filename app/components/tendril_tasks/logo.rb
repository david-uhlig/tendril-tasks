# frozen_string_literal: true

module TendrilTasks
  class Logo < TendrilTasks::Component
    DEFAULT_SIZE_RESIZE = :sm
    SIZE_RESIZE_MAPPINGS = {
      sm: 44,
      lg: 64
    }
    SIZE_RESIZE_OPTIONS = SIZE_RESIZE_MAPPINGS.keys

    style :base,
          "[&_svg]:w-auto [&_img]:w-auto"

    style :size,
          states: {
            sm: "[&_img]:h-8 [&_img]:sm:h-11 [&_svg]:h-8 [&_svg]:sm:h-11",
            lg: "[&_img]:h-12 [&_img]:sm:h-16 [&_svg]:h-12 [&_svg]:sm:h-16"
          },
          default: :sm

    def initialize(id: "brand-logo", size: :sm, **options)
      @brand = Brand.new

      options.symbolize_keys!
      options[:id] ||= id
      options[:class] = styles(base: true,
                               size: size,
                               custom: options.delete(:class))
      @options = options
      @resize_to = SIZE_RESIZE_MAPPINGS[fetch_or_fallback(SIZE_RESIZE_OPTIONS, size,  DEFAULT_SIZE_RESIZE)]
    end

    def call
      tag.div **@options do
        build_logo
      end
    end

    private

    def build_logo
      # Default logo if none was uploaded
      return image_tag("brand/logo.svg") unless @brand.logo.present?

      case @brand.logo.content_type
      when "image/svg+xml"
        # Render binary data as HTML. SVG logos are sanitized on upload.
        @brand.logo.download.html_safe
      else
        # Render all other logos as images
        image_tag rails_storage_proxy_path(
                    @brand.logo.variant(resize_to_fit: [ @resize_to, nil ])
                  )
      end
    end
  end
end
