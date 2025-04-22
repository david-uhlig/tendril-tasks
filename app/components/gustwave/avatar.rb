# frozen_string_literal: true

module Gustwave
  # Use Avatar to render a user's avatar image.
  #
  # The avatar can be either passed in with the +src+ attribute or in a block.
  # If both are present, the +src+ attribute takes precedence. The block is
  # wrapped in a +div+ element to provide consistent styling.
  #
  # === Basic Usage
  #
  #  <%= render Gustwave::Avatar.new(src: "https://example.com/avatar.png") %>
  #
  # === Passing in a Block
  #
  #  <%= render Gustwave::Avatar.new do %>
  #    <img src="https://example.com/avatar.png" alt="Avatar" />
  #  <% end %>
  #
  # You can customize the avatar's appearance using the +scheme+, +size+ and
  # +border+ options. The +scheme+ option determines the avatar's shape, the
  # +size+ option determines the avatar's size, and the +border+ option
  # determines whether the avatar has a border or not. The +border+ is
  # automatically scaled based on the +size+ option.
  #
  # @param src [String] The URL of the avatar image.
  # @param alt [String] The alt text for the avatar image.
  # @param scheme [Symbol] The scheme of the avatar, one of :round, :square.
  # @param size [Symbol] The size of the avatar, one of :xs, :sm, :md, :lg, :xl, :2xl, :3xl, :4xl.
  # @param border [Boolean] Whether the avatar should have a border.
  # @param options [Hash] HTML attributes passed to the img element.
  #
  # @see Gustwave::AvatarGroup
  # @see Gustwave::AvatarText
  # @see Gustwave::AvatarPlaceholder
  class Avatar < Gustwave::Component
    style :scheme,
          default: :round,
          states: {
            none: "",
            round: "rounded-full",
            square: "rounded"
          }

    style :size,
          default: :md,
          states: {
            none: "",
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

    style :border,
          default: :md,
          states: {
            none: "ring-1 ring-gray-300 dark:ring-gray-500",
            original: "ring-1 ring-gray-300 dark:ring-gray-500",
            xs: "ring-0 ring-gray-300 dark:ring-gray-500",
            sm: "ring-1 ring-gray-300 dark:ring-gray-500",
            md: "ring-2 ring-gray-300 dark:ring-gray-500",
            lg: "ring ring-gray-300 dark:ring-gray-500",
            xl: "ring ring-gray-300 dark:ring-gray-500",
            "2xl": "ring-4 ring-gray-300 dark:ring-gray-500",
            "3xl": "ring-4 ring-gray-300 dark:ring-gray-500",
            "4xl": "ring-8 ring-gray-300 dark:ring-gray-500"
          }

    def initialize(src: nil,
                   alt: nil,
                   scheme: :round,
                   size: :md,
                   border: false,
                   **options)
      options.deep_symbolize_keys!

      config = {
        scheme: scheme,
        size: size,
        border: (size if border),
        custom: options.delete(:class)
      }.compact_blank

      if src.present?
        options[:alt] ||= alt
        options[:role] ||= "img"
      end
      options[:class] = styles(**config)

      @src = src
      @options = options
    end

    def call
      src.present? ? image_tag(src, **options) : content_tag(:div, **options) { content }
    end

    private

    attr_reader :src, :options
  end
end
