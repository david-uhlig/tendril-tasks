# frozen_string_literal: true

module Gustwave
  module BottomNavigations
    # One item of Gustwave::BottomNavigation: a button or a link with an icon
    # and a label. Its label is shown under the icon (+:inside+), or as a
    # tooltip above the icon (+:tooltip+), where it's also the screen reader
    # name of the item.
    #
    # Set the icon with the +icon+ slot. The +icon:+ keyword is shorthand for
    # it. Block content is the label.
    #
    # Set +active: true+ for the current page or section. The item is then
    # colored blue and marked with +aria-current+.
    #
    # @example
    #   <%= render Gustwave::BottomNavigations::Item.new("Home", icon: :home, active: true) %>
    #
    # @example An icon set through the +icon+ slot
    #   <%= render Gustwave::BottomNavigations::Item.new("Wallet") do |item| %>
    #     <% item.with_icon(:wallet, theme: :solid, class: "text-red-600") %>
    #   <% end %>
    #
    # @param text [String, nil] the label of the item. Takes precedence over block content.
    # @param tag [Symbol] the HTML tag to render, +:button+ (default) or +:a+.
    # @param href [String, nil] the URL of a link item, +:a+ only.
    # @param icon [Symbol, nil] the name of the icon. Shorthand for the +icon+ slot.
    # @param active [Boolean] whether the item marks the current page or section.
    # @param label_display [Symbol] where the label is shown, +:inside+ (default) or +:tooltip+.
    # @param options [Hash] additional HTML attributes of the item element.
    #
    # @status alpha
    class Item < Gustwave::Component
      # The HTML tag to render the item as
      option :tag, default: :button, values: %i[button a]

      base "inline-flex flex-col items-center justify-center px-5 hover:bg-gray-50 dark:hover:bg-gray-800 group"

      # Gustwave's icons draw within the middle three quarters of their box,
      # so a 26px box draws them as large as Flowbite's 20px icons. The
      # negative top margin keeps Flowbite's layout.
      part :icon, "size-6.5 -mt-0.75 text-gray-500 dark:text-gray-400 group-hover:text-blue-600 dark:group-hover:text-blue-500"
      part :label, "text-sm text-gray-500 dark:text-gray-400 group-hover:text-blue-600 dark:group-hover:text-blue-500"

      # Where the label is shown. The margins are Flowbite's mb-2 and mb-1,
      # less the 3px the larger icon box adds below the drawing.
      variant :label_display, default: :inside, values: {
        inside: { icon: "mb-1.25" },
        tooltip: { icon: "mb-0.25" }
      }

      # Whether the item marks the current page or section
      toggle :active, on: {
        icon: "text-blue-600 dark:text-blue-500",
        label: "text-blue-600 dark:text-blue-500"
      }

      # The icon of the item, e.g. a Gustwave::Icon. Pass the icon's name and
      # its options, e.g. +theme:+ or +class:+, which are applied to the icon.
      #
      #   item.with_icon(:home, theme: :solid)
      renders_one_extensible :icon, ->(name, theme: :solid, **options) {
        Gustwave::Icon.new(name, theme:, **attributes_for(:icon, configure_html_attributes(options, aria: { hidden: true })))
      }

      # @param text [String, nil] the label of the item.
      # @param tag [Symbol] +:button+ or +:a+.
      # @param href [String, nil] the URL of a link item.
      # @param icon [Symbol, nil] the name of the icon.
      # @param active [Boolean] whether the item marks the current page or section.
      # @param label_display [Symbol] +:inside+ or +:tooltip+.
      # @param options [Hash] additional HTML attributes of the item element.
      def initialize(text = nil,
                     tag: DEFAULT,
                     href: nil,
                     icon: nil,
                     active: false,
                     label_display: DEFAULT,
                     **options)
        @text = text
        @href = href
        @icon = icon
        @options = options

        select_options(tag:, active:, label_display:)
        @html_tag = option_value(:tag)
        @label_display = option_value(:label_display)
      end

      # Called by Gustwave::BottomNavigation for each item. This is extension
      # API: a parent may pass more keywords later, so unknown keywords are
      # ignored.
      #
      # @param classes [String, nil] the classes the parent gives the item, e.g. its position's edge rounding. The caller's +class:+ still wins conflicts.
      def apply_slot_context(classes: nil, **)
        @slot_classes = classes
      end

      def before_render
        # Evaluates the block first, which sets the label and the icon
        @label = text_or_content(@text)
        with_icon(@icon) if @icon && !icon?
        @tooltip = Gustwave::Tooltip.new(@label) if @label_display == :tooltip
      end

      def call
        item = content_tag(@html_tag, root_attributes) do
          safe_join([ (render(icon) if icon?), label_content ].compact)
        end

        return item unless @tooltip

        safe_join([ item, render(@tooltip) ])
      end

      private

      attr_reader :label

      def root_attributes
        attributes = @html_tag == :button ? { type: "button" }.merge(@options) : @options.dup
        attributes[:href] = @href if @html_tag == :a && @href
        if option_value(:active) && !attributes.key?(:"aria-current")
          attributes[:"aria-current"] = @html_tag == :a ? "page" : "true"
        end

        # The sr-only label already names the item, so the tooltip isn't also
        # announced through aria-describedby.
        attributes = attributes.merge(@tooltip.trigger_options.except("aria-describedby")) if @tooltip

        attributes_for(attributes.merge(class: merge_classes(@slot_classes, attributes[:class])))
      end

      def label_content
        return if label.blank?
        return sr_only(label) if @label_display == :tooltip

        tag.span(label, class: classes(:label))
      end
    end
  end
end
