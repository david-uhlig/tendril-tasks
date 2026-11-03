# frozen_string_literal: true

module Gustwave
  # Use TableFoot to render an HTML table tfoot element
  #
  # To render a single row of cells, use +with_row+.
  # For more flexibility, pass in a block. The block gets appended after the
  # rows (if any).
  #
  # === Basic Usage
  #
  # Use +with_row+ to pass in a footer row, then +with_cell_th+ and +with_cell_td+
  # to pass in its cells.
  #
  #   <%= render Gustwave::TableFoot.new do |tfoot| %>
  #     <% row = tfoot.with_row %>
  #     <% row.with_cell_th do %>Total<% end %>
  #     <% row.with_cell_td do %>3<% end %>
  #   <% end %>
  #
  # === Usage with Block
  #
  # Alternatively, you can pass in block content. In this case, you must wrap
  # the cells in a +<tr>+ element.
  #
  #   <%= render Gustwave::TableFoot.new do %>
  #     <tr>
  #       <th scope="row">Total</th>
  #       <td>3</td>
  #     </tr>
  #   <% end %>
  class TableFoot < Gustwave::Component
    renders_many_extensible :rows, "Row"

    # @param options [Hash] additional options for the HTML tag, like class
    def initialize(**options)
      @config = attributes_for(options)
    end

    def call
      tag.tfoot **config do
        slots_and_content(rows)
      end
    end

    private
    attr_reader :config

    class Row < Gustwave::Component
      base "font-semibold text-gray-900 dark:text-white"

      part :cell, "px-6 py-3"
      part :header_cell, "px-6 py-3 text-base"

      renders_many_extensible :cells, types: {
        td: ->(text = nil, **options) {
          Gustwave::TableCell.new(text, tag: :td, **attributes_for(:cell, options))
        },
        th: ->(text = nil, **options) {
          config = { tag: :th, scope: "row" }.merge(attributes_for(:header_cell, options))
          Gustwave::TableCell.new(text, **config)
        }
      }

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
end
