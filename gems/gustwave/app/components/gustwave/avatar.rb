# frozen_string_literal: true

module Gustwave
  # Use Avatar to render a user's avatar image.
  #
  # The image comes from +src+ or from the block. With both, +src+ wins.
  #
  #  <%= render Gustwave::Avatar.new(src: "https://example.com/avatar.png") %>
  #
  #  <%= render Gustwave::Avatar.new do %>
  #    <img src="https://example.com/avatar.png" alt="Avatar" />
  #  <% end %>
  #
  # @see Gustwave::AvatarGroup
  # @see Gustwave::AvatarText
  # @see Gustwave::AvatarPlaceholder
  #
  # @status alpha
  class Avatar < Gustwave::Component
    # The element wrapping the block when there is no +src+
    option :tag, default: :div, values: %i[div span]

    variant :shape, default: :round, values: {
      round: "rounded-full",
      square: "rounded-sm"
    }

    variant :size, default: :md, values: {
      original: "",
      xs: "w-6 h-6",
      sm: "w-8 h-8",
      md: "w-10 h-10",
      lg: "w-12 h-12",
      xl: "w-16 h-16",
      "2xl": "w-20 h-20",
      "3xl": "w-28 h-28",
      "4xl": "w-36 h-36"
    }

    toggle :border, per: :size, values: {
      none: "ring-1 ring-gray-300 dark:ring-gray-500",
      original: "ring-1 ring-gray-300 dark:ring-gray-500",
      xs: "ring-0 ring-gray-300 dark:ring-gray-500",
      sm: "ring-1 ring-gray-300 dark:ring-gray-500",
      md: "ring-2 ring-gray-300 dark:ring-gray-500",
      lg: "ring-3 ring-gray-300 dark:ring-gray-500",
      xl: "ring-3 ring-gray-300 dark:ring-gray-500",
      "2xl": "ring-4 ring-gray-300 dark:ring-gray-500",
      "3xl": "ring-4 ring-gray-300 dark:ring-gray-500",
      "4xl": "ring-8 ring-gray-300 dark:ring-gray-500"
    }

    # @param src [String, nil] the URL of the image. Takes precedence over the block.
    # @param alt [String, nil] the alt text of the image.
    # @param shape [Symbol] Defaults to +:round+. Valid values are +:round+ and +:square+.
    # @param size [Symbol] Defaults to +:md+. Valid values are +:original+, +:xs+, +:sm+, +:md+, +:lg+, +:xl+, +:"2xl"+, +:"3xl"+ and +:"4xl"+.
    # @param border [Boolean] whether the avatar has a ring around it, as thick as its size calls for. Defaults to +false+.
    # @param tag [Symbol] the element that wraps the block when there is no +src+. Defaults to +:div+. Valid values are +:div+ and +:span+, e.g. inside a button.
    # @param options [Hash] the HTML attributes of the +<img>+, or of the wrapper without +src+.
    def initialize(src: nil,
                   alt: nil,
                   shape: DEFAULT,
                   size: DEFAULT,
                   border: false,
                   tag: DEFAULT,
                   **options)
      options.deep_symbolize_keys!
      if src.present?
        options[:alt] ||= alt
        options[:role] ||= "img"
      end
      select_options(tag:, shape:, size:, border:)

      @src = src
      @wrapper_tag = option_value(:tag)
      @options = attributes_for(options)
    end

    def call
      src.present? ? image_tag(src, **options) : content_tag(wrapper_tag, **options) { content }
    end

    private

    attr_reader :src, :wrapper_tag, :options
  end
end
