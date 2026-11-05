# frozen_string_literal: true

module Gustwave
  class Breadcrumb < Gustwave::Component
    # One item of a Gustwave::Breadcrumb, set with +with_item+. The breadcrumb
    # sets its position, its separator and whether it's the current page. An
    # item with an +href+ is a link; without one it's the text of the current
    # page. Block content replaces the link or text, e.g. for a dropdown.
    #
    # Pass +icon+ to show an icon before the text, or set it with +with_icon+.
    #
    # === Example
    #
    #   <%= render Gustwave::Breadcrumb::Item.new("Home", href: "/", icon: :home) %>
    #
    # @param text [String, nil] The item text. Takes precedence over block content.
    # @param href [String, nil] The URL the item links to.
    # @param icon [Symbol, nil] Shorthand for +with_icon+: an icon shown before the text.
    # @param separator [Symbol] +:chevron+ (default) or +:slash+. Set by Gustwave::Breadcrumb.
    # @param options [Hash] HTML attributes for the +li+ element.
    #
    # @status alpha
    class Item < Gustwave::Component
      part :wrapper
      part :separator
      part :content

      # The first item is the first +li+ of the list. The other items hold a
      # separator before their content. Set by Gustwave::Breadcrumb.
      variant :position, default: :first, internal: true, values: {
        first: { root: "inline-flex items-center", content: "inline-flex items-center text-sm font-medium" },
        other: { wrapper: "flex items-center", content: "ms-1 text-sm font-medium md:ms-2" }
      }

      # Set by the item: a link, or the text of the current page
      toggle :linked,
             on: "text-gray-700 hover:text-blue-600 dark:text-gray-400 dark:hover:text-white",
             off: "text-gray-500 dark:text-gray-400",
             part: :content,
             internal: true

      # Chevrons fill a small part of their 24x24 viewBox. These sizes match the
      # chevron drawn by Flowbite's w-3 icon, as in Gustwave::Pagination::Link.
      variant :separator, part: :separator, default: :chevron, values: {
        chevron: "w-6 h-6 -mx-[7px] rtl:rotate-180 text-gray-400",
        slash: "mx-2 text-gray-400"
      }

      renders_one_extensible :icon, ->(name, theme: :solid, **options) {
        Gustwave::Icon.new(name, theme:, **configure_html_attributes(options, class: "w-3 h-3 me-2.5", aria: { hidden: true }))
      }

      # @param text [String, nil] The item text. Takes precedence over block content.
      # @param href [String, nil] The URL the item links to.
      # @param icon [Symbol, nil] An icon shown before the text.
      # @param separator [Symbol] +:chevron+ (default) or +:slash+.
      # @param options [Hash] HTML attributes for the +li+ element.
      def initialize(text = nil, href: nil, icon: nil, separator: DEFAULT, **options)
        @text = text
        @href = href
        @icon = icon
        select_options(separator:)
        @options = options
      end

      # Called by Gustwave::Breadcrumb. Each keyword is optional: a call with one
      # keyword leaves the other unchanged.
      #
      # @param position [Symbol, nil] +:first+ for the first item, otherwise +:other+.
      # @param current [Boolean, nil] Whether the item is the current page.
      # @param separator [Symbol, nil] +:chevron+ or +:slash+.
      def apply_slot_context(position: nil, current: nil, separator: nil, **)
        select_options(position:) if position
        select_options(separator:) if separator
        @current = current unless current.nil?
      end

      def before_render
        with_icon(@icon) if @icon && !icon?
        select_options(linked: @href.present?)
        @config = attributes_for(@options)
        @config[:"aria-current"] = "page" if @current
      end

      def call
        tag.li(**@config) do
          if option_value(:position) == :first
            content_element
          else
            tag.div(class: classes(:wrapper)) { safe_join([ separator_element, content_element ]) }
          end
        end
      end

      private

      # Block content without text replaces the link or text, without a wrapper
      def content_element
        return safe_join([ leading_icon, content ]) if @text.blank? && content.present?

        label = safe_join([ leading_icon, @text ].compact)
        if option_value(:linked)
          render Gustwave::Link.new(label, href: @href, color: :none, underline: :none, class: classes(:content))
        else
          tag.span(label, class: classes(:content))
        end
      end

      def leading_icon
        icon if icon?
      end

      def separator_element
        if option_value(:separator) == :slash
          tag.span("/", class: classes(:separator), aria: { hidden: true })
        else
          render Gustwave::Icon.new(:chevron_right, class: classes(:separator), aria: { hidden: true })
        end
      end
    end
  end
end
