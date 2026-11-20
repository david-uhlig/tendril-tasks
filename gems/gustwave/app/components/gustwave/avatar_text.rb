# frozen_string_literal: true

module Gustwave
  # Use AvatarText to render text when no image is available.
  #
  # E.g. initials, or the "+99" that ends a shortened AvatarGroup. The text's
  # size follows the avatar's. A block replaces the text, without that
  # sizing:
  #
  #   render Gustwave::AvatarText.new("AB", size: :lg)
  #   render Gustwave::AvatarText.new(size: :lg) do
  #     tag.div "Custom Content"
  #   end
  #
  # @status alpha
  class AvatarText < Gustwave::Component
    part :root, "relative inline-flex items-center justify-center overflow-hidden bg-gray-100 dark:bg-gray-600"

    part :text, "font-medium text-gray-600 dark:text-gray-300"

    # Also passed to Gustwave::Avatar.
    variant :size, part: :text, default: :md, values: {
      xs: "text-xs",
      sm: "text-sm",
      md: "text-md",
      lg: "text-lg",
      xl: "text-xl",
      "2xl": "text-2xl",
      "3xl": "text-3xl",
      "4xl": "text-4xl"
    }

    # @param text [String, nil] the text. Takes precedence over the block.
    # @param size [Symbol] the size of the avatar and its text. Defaults to +:md+. Valid values are +:xs+, +:sm+, +:md+, +:lg+, +:xl+, +:"2xl"+, +:"3xl"+ and +:"4xl"+.
    # @param options [Hash] the arguments and HTML attributes of the Gustwave::Avatar it renders, e.g. +shape+ and +border+.
    def initialize(text = nil, size: DEFAULT, **options)
      select_options(size:)
      @text = text
      @text_options = { class: classes(:text) }
      @options = { size: option_value(:size) }.merge!(attributes_for(options))
    end

    def before_render
      return unless text.present?

      @text = tag.span(text, **text_options)
    end

    def call
      render Gustwave::Avatar.new(**options) do
        text_or_content(text)
      end
    end

    private

    attr_reader :options, :text, :text_options
  end
end
