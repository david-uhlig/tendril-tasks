# frozen_string_literal: true

module Gustwave
  # Use AvatarPlaceholder to render a placeholder image when no avatar is
  # available.
  #
  # Without +src+ or a block it renders a generic person icon. A +src+ or a
  # block replaces the icon:
  #
  #   render Gustwave::AvatarPlaceholder.new
  #   render Gustwave::AvatarPlaceholder.new(src: "https://example.com/avatar.png")
  #   render Gustwave::AvatarPlaceholder.new do
  #     render Gustwave::Svg.new do
  #      "<svg>...</svg>".html_safe
  #     end
  #   end
  #
  # @status alpha
  class AvatarPlaceholder < Gustwave::Component
    # As in Flowbite, the icon is 120% of the avatar and is cropped, in percentages so it scales with every size.
    DEFAULT_PLACEHOLDER = <<~SVG
      <svg class="absolute w-[120%] h-[120%] -left-[10%] text-gray-400" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" clip-rule="evenodd"></path></svg>
    SVG

    base "relative overflow-hidden bg-gray-100 dark:bg-gray-600"

    # @param options [Hash] the arguments and HTML attributes of the Gustwave::Avatar it renders, e.g. +src+, +alt+, +shape+, +size+ and +border+.
    def initialize(**options)
      @options = attributes_for(options)
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
