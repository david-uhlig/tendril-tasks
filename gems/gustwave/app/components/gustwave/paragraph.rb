# frozen_string_literal: true

module Gustwave
  # Use Paragraph to render a block of text in a +<p>+ element.
  #
  # A paragraph has no margin, so it sits flush against its neighbours. Space
  # several paragraphs with a wrapper, e.g. +space-y-3+.
  #
  # Examples:
  #
  # Renders a gray paragraph
  #
  #   <%= render Gustwave::Paragraph.new("Track work across the enterprise.") %>
  #
  # Pass a block for content with inline elements:
  #
  #   <%= render Gustwave::Paragraph.new do %>
  #     Read the <a href="/docs">docs</a>.
  #   <% end %>
  #
  # Line the text up with a side of the container. The sides are mirrored for
  # right-to-left text:
  #
  #   <%= render Gustwave::Paragraph.new("Centered", align: :center) %>
  #
  # You can pass HTML attributes to the +<p>+ element and your css classes
  # will be merged with the default classes without style conflicts:
  #
  #   <%= render Gustwave::Paragraph.new("Dark", class: "text-gray-900") %>
  #
  # Reset the color by passing the +none+ color:
  #
  #   <%= render Gustwave::Paragraph.new("Plain", color: :none) %>
  #
  class Paragraph < Gustwave::Component
    unstyled color: :none

    variant :color, default: :default, values: {
      default: "text-gray-500 dark:text-gray-400"
    }

    # Which side the text lines up with, mirrored for right-to-left text
    variant :align, default: :none, values: {
      left: "text-left rtl:text-right",
      center: "text-center",
      right: "text-right rtl:text-left"
    }

    def initialize(text = nil, color: DEFAULT, align: DEFAULT, **options)
      @text = text
      select_options(color:, align:)
      @options = attributes_for(options)
    end

    def call
      tag.p(text_or_content, **@options)
    end
  end
end
