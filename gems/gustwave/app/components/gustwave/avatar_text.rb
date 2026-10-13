# frozen_string_literal: true

module Gustwave
  # Use AvatarText to render text when no image is available.
  #
  # This can be used to display initials or indicate that there are additional
  # elements in a shortened AvatarGroup, e.g. "+99".
  #
  # === Basic Usage
  #
  # When using the +text+ attribute, the AvatarText component will automatically
  # adjust the size of the text based on the size of the avatar. All other
  # attributes are passed to the Avatar component.
  #
  #   render Gustwave::AvatarText.new("AB", size: :lg)
  #
  # === Custom Usage
  #
  # You can also provide a block to the AvatarText component. The block will be
  # rendered inside the Avatar component, allowing you to fully customize the
  # appearance of the avatar. No automatic text-size adjustment will be
  # performed in this case. Note +text+ takes precedent over block content.
  #
  #   render Gustwave::AvatarText.new(size: :lg) do
  #     tag.div "Custom Content"
  #   end
  #
  # @param text [String] The text to display in the avatar. Takes precedent over
  #  block content.
  # @param scheme [Symbol] The scheme of the avatar, see +Gustwave::Avatar+ for
  #  available options. Default is +Gustwave::Avatar+'s default.
  # @param size [Symbol] The size of the avatar, see +Gustwave::Avatar+ for
  #   available options. Default is :md.
  # @param border [Symbol] Whether the avatar should have a border. Default is
  #  +Gustwave::Avatar+'s default.
  class AvatarText < Gustwave::Component
    style :base,
          "relative inline-flex items-center justify-center overflow-hidden bg-gray-100 dark:bg-gray-600"

    style :text_base,
          "font-medium text-gray-600"

    style :text_size,
          default: :md,
          states: {
            xs: "text-xs",
            sm: "text-sm",
            md: "text-md",
            lg: "text-lg",
            xl: "text-xl",
            "2xl": "text-2xl",
            "3xl": "text-3xl",
            "4xl": "text-4xl"
          }

    def initialize(text = nil,
                   scheme: nil,
                   size: :md,
                   border: nil,
                   **options)
      options.deep_symbolize_keys!
      options[:class] = styles(base: true, custom: options.delete(:class))
      kwargs = { scheme:, size:, border: }.compact

      @text = text
      @text_options = { class: styles(text_base: true, text_size: size) }
      @options = kwargs.merge!(options)
    end

    def before_render
      return unless text.present?

      @text = tag.span(text, **text_options)
    end

    def call
      render Gustwave::Avatar.new(**options) do
        text_or_content
      end
    end

    private

    attr_reader :options, :text, :text_options
  end
end
