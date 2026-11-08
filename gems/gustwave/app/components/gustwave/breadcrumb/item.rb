# frozen_string_literal: true

module Gustwave
  class Breadcrumb < Gustwave::Component
    # One item of a Gustwave::Breadcrumb, set with +with_item+. The breadcrumb
    # sets its position, its separator and whether it's the current page. An
    # item with an +href+ is a link; without one it's the text of the current
    # page. Block content replaces the link or text, e.g. for a dropdown.
    #
    # Pass +icon+ to show an icon before the text, or set a visual with
    # +with_visual_icon+ and the other types of Gustwave::Visuals.
    #
    # === Example
    #
    #   <%= render Gustwave::Breadcrumb::Item.new("Home", href: "/", icon: :home) %>
    #
    # @param text [String, nil] The item text. Takes precedence over block content.
    # @param href [String, nil] The URL the item links to.
    # @param icon [Symbol, nil] Shorthand for +with_visual_icon+: an icon shown before the text, in the solid theme.
    # @param separator [Symbol] +:chevron+ (default) or +:slash+. Set by Gustwave::Breadcrumb.
    # @param options [Hash] HTML attributes for the +li+ element.
    #
    # @status alpha
    class Item < Gustwave::Component
      include Gustwave::Visuals
      renders_visuals :visuals
      self.visual_icon_theme = :solid

      # Gustwave's icons leave 3 units of their 24x24 viewBox empty on each
      # side. At w-4 the glyph is as large as Flowbite's w-3 icon, and the
      # margins make up for the empty part.
      part :visual, "w-4 h-4 -ms-0.5 me-2 -my-0.5"
      part :wrapper
      part :separator
      part :content

      # The first item is the first +li+ of the list. The other items hold a
      # separator before their content. Set by Gustwave::Breadcrumb.
      variant :position, default: :first, internal: true, values: {
        first: { root: "inline-flex items-center", content: "inline-flex items-center text-sm font-medium" },
        other: { wrapper: "flex items-center", content: "text-sm font-medium" }
      }

      # Set by the item: a link, or the text of the current page
      toggle :linked,
             on: "text-gray-700 hover:text-blue-600 dark:text-gray-400 dark:hover:text-white",
             off: "text-gray-500 dark:text-gray-400",
             part: :content,
             internal: true

      # The chevron is Flowbite's own 6x10 glyph, +chevron_right_compact+. With a
      # chevron the content is indented, as in Flowbite; a slash has its own margins.
      variant :separator, default: :chevron, unless: { position: :first }, values: {
        chevron: { separator: "w-3 h-3 mx-1 rtl:rotate-180 text-gray-400", content: "ms-1 md:ms-2" },
        slash: { separator: "mx-2 text-gray-400" }
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
        with_visual_icon(@icon) if @icon && !visuals?
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

      # Block content without text replaces the link or text. It's set in the
      # item's text style, so plain text in the block looks like the other items.
      def content_element
        if @text.blank? && content.present?
          return tag.div(class: classes(:content, class: "inline-flex items-center")) { safe_join([ leading_icon, content ]) }
        end

        label = safe_join([ leading_icon, @text ].compact)
        if option_value(:linked)
          render Gustwave::Link.new(label, href: @href, color: :none, underline: :none, class: classes(:content))
        else
          tag.span(label, class: classes(:content))
        end
      end

      def leading_icon
        safe_join(visuals) if visuals?
      end

      def separator_element
        if option_value(:separator) == :slash
          tag.span("/", class: classes(:separator), aria: { hidden: true })
        else
          render Gustwave::Icon.new(:chevron_right_compact, class: classes(:separator), aria: { hidden: true })
        end
      end
    end
  end
end
