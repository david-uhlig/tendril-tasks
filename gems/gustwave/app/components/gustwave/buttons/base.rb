# frozen_string_literal: true

module Gustwave
  module Buttons
    # Use Base as a building block for button themes
    #
    # Renders leading and trailing visuals, see Gustwave::Visuals.
    class Base < Gustwave::Component
      include Gustwave::Visuals

      # The HTML tag to render the button as
      option :tag, default: :button, values: %i[button a]

      # The +type+ attribute. Only rendered for the +:button+ tag.
      option :type, default: :button, values: %i[button reset submit]

      base "rounded-lg focus:outline-hidden focus:ring-4 text-center overflow-hidden whitespace-nowrap align-bottom disabled:cursor-not-allowed"
      unstyled scheme: :none

      # General appearance of the buttons. +:base+ renders only the base
      # styles.
      #
      # Extend it with your own values when inheriting from this class:
      #
      #   extend_variant :scheme, default: :red, values: {
      #     red: "bg-red-500 hover:bg-red-600 focus:ring-red-300",
      #     green: "bg-green-500 hover:bg-green-600 focus:ring-green-300"
      #   }
      variant :scheme, default: :base, values: { base: "" }

      # The +visual+ part sizes leading and trailing visuals to match the
      # +text-*+ class of the button.
      variant :size, default: :md, values: {
        xs: { root: "h-8 px-3 py-2 text-xs font-medium", visual: "h-4 w-auto" },
        sm: { root: "h-9 px-3 py-2 text-sm font-medium", visual: "h-5 w-auto" },
        md: { root: "h-10 px-5 py-2.5 text-sm font-medium", visual: "h-5 w-auto" },
        lg: { root: "h-12 px-5 py-3 text-base font-medium", visual: "h-6 w-auto" },
        xl: { root: "h-13 px-6 py-3.5 text-base font-medium", visual: "h-7 w-auto" }
      }

      # The size of leading and trailing indicators per button size. Extend it
      # along with +size+, e.g. with +:auto+ to scale with the button text.
      derive :indicator_size, from: :size, values: {
        none: :none,
        xs: :sm,
        sm: :sm,
        md: :md,
        lg: :md,
        xl: :lg
      }

      toggle :pill, "rounded-full"

      # Set when no text or content block was given, to render a square button
      toggle :visual_only, per: :size, values: {
        xs: "p-2",
        sm: "p-2",
        md: "p-2.5",
        lg: "p-3",
        xl: "p-3.5"
      }

      # @param text [String, nil] text to display on the button. Takes precedence over block content.
      # @param tag [Symbol] The HTML tag to use for the button. Options: :a and :button. Defaults to :button.
      # @param type [Symbol] The type of button. Options: :button, :reset, :submit. Defaults to :button.
      # @param scheme [Symbol] The color scheme of the button. Options: :none and :base.
      # @param size [Symbol] The size of the button. Options: :none, :xs, :sm, :md, :lg, :xl.
      # @param pill [Boolean] Whether to render the button in pill shape.
      # @param options [Hash] HTML attributes to be applied to the button.
      def initialize(text = nil,
                     tag: DEFAULT,
                     type: DEFAULT,
                     scheme: DEFAULT,
                     size: DEFAULT,
                     pill: false,
                     **options)
        @text = text
        @options = options

        select_options(tag:, type:, scheme:, size:, pill:)
        @html_tag = option_value(:tag)
        @scheme = option_value(:scheme)
      end

      def before_render
        # Must build config here to know whether block content was passed
        select_options(has_visual: has_visual?, visual_only: !has_content?)
        @config = { type: type_attribute }.merge(attributes_for(@options))
      end

      def call
        content_tag html_tag, config do
          slots_and_content(leading_visuals, text_or_content, trailing_visuals, append_content: false)
        end
      end

      private
      attr_reader :html_tag, :config, :scheme

      # The value of the +type+ attribute, or +nil+ to render none
      def type_attribute
        option_value(:type) if html_tag == :button
      end

      def has_content?
        @has_content ||= text_or_content.present?
      end
    end
  end
end
