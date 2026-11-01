# frozen_string_literal: true

module Gustwave
  module SpeedDials
    # One action button of a speed dial: an icon with a label.
    #
    # The label is shown as a tooltip beside the button (+:tooltip+), as text
    # inside the button below the icon (+:inside+), or as text next to the
    # button (+:outside+). The side of the tooltip, or of the outside label, is
    # set by +label_placement+.
    #
    # Block content replaces the icon.
    #
    # @example
    #   <%= render Gustwave::SpeedDials::Action.new("Edit", icon: :edit, label_display: :outside) %>
    #
    # @param text [String] the label of the action. Required.
    # @param icon [Symbol, nil] the name of the icon. Ignored when block content is given.
    # @param icon_theme [Symbol] the theme of the icon, +:solid+ (default) or +:outline+.
    # @param tag [Symbol] the HTML tag to render, :button or :a. Defaults to :button.
    # @param color [Symbol] the color of the button, :default or :none. :none renders no base styles.
    # @param shape [Symbol] the shape of the button, :round or :square.
    # @param label_display [Symbol] where the label is shown, :tooltip, :inside or :outside.
    # @param label_placement [Symbol] the side of the label, :left, :right, :top or :bottom.
    # @param options [Hash] HTML attributes, e.g. +href+ for the :a tag.
    class Action < Gustwave::Component
      # The HTML tag to render the action as
      option :tag, default: :button, values: %i[button a]

      unstyled color: :none
      base "flex flex-col items-center justify-center shadow-xs focus:ring-4 focus:outline-hidden"

      variant :color, default: :default, values: {
        default: "text-gray-500 hover:text-gray-900 bg-white border border-gray-200 hover:bg-gray-50 focus:ring-gray-300 " \
                 "dark:border-gray-600 dark:text-gray-400 dark:hover:text-white dark:bg-gray-700 dark:hover:bg-gray-600 dark:focus:ring-gray-400"
      }

      variant :shape, default: :round, values: { round: "rounded-full", square: "rounded-lg" }

      part :icon
      part :inside_label, "block mb-px text-xs font-medium"
      part :outside_label, "absolute text-sm font-medium whitespace-nowrap"

      # Where the label is shown. The icons are padded within their viewBox, so
      # these sizes draw them as large as Flowbite draws its tighter icons.
      variant :label_display, default: :tooltip, values: {
        tooltip: { root: "size-13",          icon: "size-6.5" },
        inside:  { root: "size-14",          icon: "size-5.5 mb-1" },
        outside: { root: "relative size-13", icon: "size-6.5" }
      }

      # The side of the label: the tooltip's placement, or the side of the outside label
      variant :label_placement, part: :outside_label, default: :left, values: {
        left:   "end-full me-3 top-1/2 -translate-y-1/2",
        right:  "start-full ms-3 top-1/2 -translate-y-1/2",
        top:    "bottom-full mb-2 start-1/2 -translate-x-1/2 rtl:translate-x-1/2",
        bottom: "top-full mt-2 start-1/2 -translate-x-1/2 rtl:translate-x-1/2"
      }

      def initialize(text,
                     icon: nil,
                     icon_theme: :solid,
                     tag: DEFAULT,
                     color: DEFAULT,
                     shape: DEFAULT,
                     label_display: DEFAULT,
                     label_placement: DEFAULT,
                     **options)
        @text = text
        @icon = icon
        @icon_theme = icon_theme

        select_options(tag:, color:, shape:, label_display:, label_placement:)
        @html_tag = option_value(:tag)
        @label_display = option_value(:label_display)
        @label_placement = option_value(:label_placement)
        @tooltip = Gustwave::Tooltip.new(text)
        @options = attributes_for(options)
      end

      def call
        trigger = content_tag(html_tag, trigger_attributes) do
          safe_join([ icon_content, label_content ].compact)
        end

        return trigger unless label_display == :tooltip

        safe_join([ trigger, render(tooltip) ])
      end

      private

      attr_reader :text, :icon, :icon_theme, :html_tag, :label_display, :label_placement, :options, :tooltip

      # The +type+ attribute is only set for the button tag. A caller's +type+ wins.
      def trigger_attributes
        attributes = html_tag == :button ? { type: "button" }.merge(options) : options
        return attributes unless label_display == :tooltip

        # The sr-only label already names the button, so the tooltip is not
        # also announced through aria-describedby.
        attributes.merge(tooltip.trigger_options(placement: label_placement).except("aria-describedby"))
      end

      def icon_content
        return content if content.present?
        return if icon.blank?

        render Gustwave::Icon.new(icon, theme: icon_theme, class: classes(:icon), aria: { hidden: true })
      end

      def label_content
        case label_display
        when :tooltip then sr_only(text)
        when :inside then tag.span(text, class: classes(:inside_label))
        when :outside then tag.span(text, class: classes(:outside_label))
        end
      end
    end
  end
end
