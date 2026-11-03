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
      unstyled color: :none

      # General appearance of the buttons. +:base+ renders only the base
      # styles.
      #
      # Extend it with your own values when inheriting from this class:
      #
      #   extend_variant :color, default: :red, values: {
      #     red: "bg-red-500 hover:bg-red-600 focus:ring-red-300",
      #     green: "bg-green-500 hover:bg-green-600 focus:ring-green-300"
      #   }
      variant :color, default: :base, values: { base: "" }

      # The +visual+ part sizes leading and trailing visuals to match the
      # +text-*+ class of the button. The icon boxes are 4px larger than
      # Flowbite's, because Gustwave's icons leave a margin around their
      # drawing. The negative margin keeps Flowbite's layout. Heights come from
      # padding and line height, so a border adds to them as in Flowbite.
      variant :size, default: :md, values: {
        xs: { root: "px-3 py-2 text-xs font-medium gap-2", visual: "h-4 w-auto -mx-0.5" },
        sm: { root: "px-3 py-2 text-sm font-medium gap-2", visual: "h-4 w-auto -mx-0.5" },
        md: { root: "px-5 py-2.5 text-sm font-medium gap-2", visual: "h-4.5 w-auto -mx-0.5" },
        lg: { root: "px-5 py-3 text-base font-medium gap-2", visual: "h-5 w-auto -mx-0.5" },
        xl: { root: "px-6 py-3.5 text-base font-medium gap-2", visual: "h-5 w-auto -mx-0.5" }
      }

      # The size of leading and trailing indicators per button size. Extend it
      # along with +size+, e.g. with +:auto+ to scale with the button text.
      derive :indicator_size, from: :size, values: {
        none: :none,
        xs: :sm,
        sm: :sm,
        md: :lg,
        lg: :lg,
        xl: :xl
      }

      toggle :pill, "rounded-full"

      # Set when no text or content block was given, to render a square button.
      # Its +*:+ classes size the icon of an icon-only button, because the size
      # variant's visual classes are for an icon beside text.
      toggle :visual_only, per: :size, internal: true, values: {
        xs: "p-2 *:h-4 *:mx-0",
        sm: "p-2 *:h-5 *:mx-0",
        md: "p-2.5 *:h-5 *:mx-0",
        lg: "p-3 *:h-6 *:mx-0",
        xl: "p-3.5 *:h-7 *:mx-0"
      }

      # @param text [String, nil] text to display on the button. Takes precedence over block content.
      # @param tag [Symbol] The HTML tag to use for the button. Options: :a and :button. Defaults to :button.
      # @param type [Symbol] The type of button. Options: :button, :reset, :submit. Defaults to :button.
      # @param color [Symbol] The color of the button. Options: :none and :base.
      # @param size [Symbol] The size of the button. Options: :none, :xs, :sm, :md, :lg, :xl.
      # @param pill [Boolean] Whether to render the button in pill shape.
      # @param options [Hash] HTML attributes to be applied to the button.
      def initialize(text = nil,
                     tag: DEFAULT,
                     type: DEFAULT,
                     color: DEFAULT,
                     size: DEFAULT,
                     pill: false,
                     **options)
        @text = text
        @options = options

        select_options(tag:, type:, color:, size:, pill:)
        @html_tag = option_value(:tag)
        @color = option_value(:color)
      end

      def before_render
        # Must build config here to know whether block content was passed
        select_options(has_visual: has_visual?, visual_only: !has_content?)
        @config = { type: type_attribute }.merge(attributes_for(@options))
      end

      def call
        content_tag html_tag, config do
          slots_and_content(leading_visuals, text_or_content(text), trailing_visuals, append_content: false)
        end
      end

      private
      attr_reader :html_tag, :config, :color, :text

      # The value of the +type+ attribute, or +nil+ to render none
      def type_attribute
        option_value(:type) if html_tag == :button
      end

      def has_content?
        text_or_content(text).present?
      end
    end
  end
end
