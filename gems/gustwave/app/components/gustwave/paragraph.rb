# frozen_string_literal: true

module Gustwave
  # Use Paragraph to render a block of text in a +<p>+ element.
  #
  # A paragraph has no margin, so it sits flush against its neighbours. Space
  # several paragraphs with a wrapper, e.g. +space-y-3+.
  #
  #   <%= render Gustwave::Paragraph.new("Track work across the enterprise.") %>
  #   <%= render Gustwave::Paragraph.new("Centered", align: :center) %>
  #   <%= render Gustwave::Paragraph.new do %>
  #     Read the <a href="/docs">docs</a>.
  #   <% end %>
  #
  # @status alpha
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

    # @param text [String, nil] the text. Without it the block is the content.
    # @param color [Symbol] Defaults to +:default+, gray. +:none+ adds no color classes.
    # @param align [Symbol] the side the text lines up with, mirrored for right-to-left text. Defaults to +:none+. Valid values are +:none+, +:left+, +:center+ and +:right+.
    # @param options [Hash] the HTML attributes of the +<p>+.
    def initialize(text = nil, color: DEFAULT, align: DEFAULT, **options)
      @text = text
      select_options(color:, align:)
      @options = attributes_for(options)
    end

    def call
      tag.p(text_or_content(text), **@options)
    end

    private

    attr_reader :text
  end
end
