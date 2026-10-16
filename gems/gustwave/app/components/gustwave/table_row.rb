# frozen_string_literal: true

module Gustwave
  # Use TableRow to render an HTML table row
  #
  # \Table cells can be provided through slots or by passing in block content.
  # The +td+ slot (alias +cell+) renders a +<td>+ HTML element. The +th+ slot
  # (alias: +head+) renders a +<th scope="row">+ element. Block content gets
  # appended at the end of any provided cells.
  #
  # === Basic Usage
  #
  # Use the +th+ and +td+ slots to pass in table cells.
  #
  #   <%= render Gustwave::TableRow.new do |tr| %>
  #     <% tr.th do %>John Doe<% end %>
  #     <% tr.td do %>Software Engineer<% end %>
  #   <% end %>
  #
  # === Usage with Block
  #
  # Alternatively, you can pass in block content..
  #
  #   <%= render Gustwave::TableRow.new do %>
  #     <th>John Doe</th>
  #     <td>Software Engineer</td>
  #   <% end %>
  class TableRow < Gustwave::Component
    base "bg-white border-b dark:bg-gray-800 dark:border-gray-700 border-gray-200"

    part :header_cell, "font-medium text-gray-900 dark:text-white whitespace-nowrap"

    renders_many_extensible :cells, types: {
      td: ->(text = nil, **options) {
        Gustwave::TableCell.new(text, tag: :td, **options)
      },
      th: ->(text = nil, **options) {
        config = { tag: :th, scope: "row" }.merge(attributes_for(:header_cell, options))
        Gustwave::TableCell.new(text, **config)
      }
    }
    alias cell with_cell_td
    alias td with_cell_td
    alias head with_cell_th
    alias th with_cell_th

    # @param options [Hash] additional options for the HTML tag.
    def initialize(**options)
      @config = attributes_for(options)
    end

    def call
      tag.tr **config do
        slots_and_content(cells)
      end
    end

    private
    attr_reader :config
  end
end
