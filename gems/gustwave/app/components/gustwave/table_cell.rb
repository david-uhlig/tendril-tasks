# frozen_string_literal: true

module Gustwave
  # Use TableCell to render an HTML table data cell (td) or a table header
  # element (th)
  #
  # === Basic Usage
  #
  # The text attribute provides a way to render simple text content without
  # having to use a block.
  #
  #   <%= render Gustwave::TableCell.new("John Doe") %>
  #   # => <td class="px-6 py-4">John Doe</td>
  #
  # === Usage with block
  #
  # Supply a block for complex content.
  #
  #   <%= render Gustwave::TableCell.new do %>
  #     <span>John Doe</span>
  #   <% end %>
  #   # => <td class="px-6 py-4"><span>John Doe</span></td>
  class TableCell < Gustwave::Component
    base "px-6 py-4"

    option :tag, default: :td, values: %i[td th]

    # @param text [String] text to display inside the cell. Takes precedent over block content.
    # @param tag [Symbol] HTML tag for the table cell, usually :td or :th.
    # @param options [Hash] additional options for the HTML tag.
    def initialize(text = nil, tag: DEFAULT, **options)
      select_options(tag:)
      @tag = option_value(:tag)
      @text = text
      @config = attributes_for(options)
    end

    def call
      content_tag(tag, **config) do
        text_or_content(text)
      end
    end

    private
    attr_reader :config, :tag, :text
  end
end
