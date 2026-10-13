# frozen_string_literal: true

module Gustwave
  # Use AvatarPlaceholder to render a placeholder image when no avatar is
  # available.
  #
  # With default options, it renders a default placeholder image with the
  # default +Gustwave::Avatar+ options. You can supply a custom placeholder
  # through the +src+ attribute, or by providing a block.
  #
  # === Basic Usage
  #
  # Renders the default placeholder image with default styling.
  #
  #   render Gustwave::AvatarPlaceholder.new
  #
  # === Custom Usage
  #
  # Renders the +src+ image with default styling.
  #
  #   render Gustwave::AvatarPlaceholder.new(src: "https://example.com/avatar.png")
  #
  # Renders the block content with default styling.
  #
  #   render Gustwave::AvatarPlaceholder.new do
  #     render Gustwave::Svg.new do
  #      "<svg>...</svg>".html_safe
  #     end
  #   end
  #
  # @param src [String] The source URL of the placeholder image. Passed to the
  #  +Gustwave::Avatar+ component.
  # @param alt [String] The alt text for the placeholder image. Passed to the
  #  +Gustwave::Avatar+ component.
  # @param scheme [Symbol] The scheme of the placeholder image. Passed to the
  #  +Gustwave::Avatar+ component.
  # @param size [Symbol] The size of the placeholder image. Passed to the
  #  +Gustwave::Avatar+ component.
  # @param border [Boolean] Whether to render a border. Passed to the
  #  +Gustwave::Avatar+ component.
  # @param options [Hash] Additional HTML attributes passed to the
  #  +Gustwave::Avatar+ component.
  class AvatarPlaceholder < Gustwave::Component
    DEFAULT_PLACEHOLDER = <<~SVG
      <svg class="absolute text-gray-400 -bottom-1" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" clip-rule="evenodd"></path></svg>
    SVG

    style :base,
          "relative overflow-hidden bg-gray-100 dark:bg-gray-600"

    def initialize(src: nil,
                   alt: nil,
                   scheme: nil,
                   size: nil,
                   border: nil,
                   **options)
      options.deep_symbolize_keys!
      options[:class] = styles(base: true, custom: options.delete(:class))
      kwargs = { src:, alt:, scheme:, size:, border: }.compact

      @options = kwargs.merge!(options)
    end

    def call
      if custom_placeholder?
        render Gustwave::Avatar.new(**options) do
          content
        end
      else
        render Gustwave::Avatar.new(**options) do
          render Gustwave::Svg.new do
            DEFAULT_PLACEHOLDER.html_safe
          end
        end
      end
    end

    private

    attr_reader :options

    def custom_placeholder?
      options[:src].present? || content.present?
    end
  end
end
