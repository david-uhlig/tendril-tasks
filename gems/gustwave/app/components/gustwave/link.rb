# frozen_string_literal: true

module Gustwave
  # Use Link for text that takes the user to another page. Use +Button+ for
  # actions, or +Button+ with +tag: :a+ for a link that looks like a button.
  #
  # Examples:
  #
  # Renders a blue link that underlines on hover
  #
  #   <%= render Gustwave::Link.new("Read more", href: "/docs") %>
  #
  # Keep the underline in running text, so the link stands out without color:
  #
  #   <%= render Gustwave::Paragraph.new do %>
  #     Read our <%= render Gustwave::Link.new("roadmap", href: "/roadmap", underline: :always) %>.
  #   <% end %>
  #
  # Pass a block to compose a link with other elements, e.g. an icon:
  #
  #   <%= render Gustwave::Link.new(href: "/stories", class: "inline-flex items-center") do %>
  #     Read their stories
  #     <%= render Gustwave::Icon.new(:arrow_right, class: "ms-2 rtl:rotate-180") %>
  #   <% end %>
  #
  # Inherit the surrounding text style with the +none+ color:
  #
  #   <%= render Gustwave::Link.new("Imprint", href: "/imprint", color: :none) %>
  #
  class Link < Gustwave::Component
    base "font-medium"
    unstyled color: :none

    variant :color, default: :default, values: {
      default: "text-blue-600 dark:text-blue-500"
    }

    # When the link shows its underline
    variant :underline, default: :hover, values: {
      hover: "hover:underline",
      always: "underline hover:no-underline"
    }

    # @param text [String, nil] The link text. Pass a block for other content.
    # @param color [Symbol] The text color. Use +:none+ to inherit the surrounding text style.
    # @param underline [Symbol] When the link shows its underline, +:hover+ or +:always+.
    # @param options [Hash] Additional HTML attributes passed to the +<a>+ element, e.g. +href+, +id+ or +class+.
    def initialize(text = nil, color: DEFAULT, underline: DEFAULT, **options)
      @text = text
      select_options(color:, underline:)
      @options = attributes_for(options)
    end

    def call
      tag.a(text_or_content(text), **@options)
    end

    private

    attr_reader :text
  end
end
