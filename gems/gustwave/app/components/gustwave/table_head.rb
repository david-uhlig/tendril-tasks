# frozen_string_literal: true

module Gustwave
  # Use TableHead to render an HTML table thead element
  #
  # To render a single row of +<th scope='col'>+ cells, use the +th+ slots
  # (aliases: +column+, +col+). For more flexibility, pass in a block. The block
  # gets appended after the row of +th+ cells (if any).
  #
  # === Basic Usage
  #
  # Use the simplified text argument or supply a block to the +th+ slots.
  #
  #   <%= render Gustwave::TableHead.new do |thead| %>
  #     <%= thead.th "First Name" %>
  #     <%= thead.th do %>Last Name<% end %>
  #   <% end %>
  #
  # === Usage with Block
  #
  # Alternatively, you can pass in a block to the +TableHead+ component. In this
  # case, you must wrap the +<th>+ cells in a +<tr>+ element.
  #
  #   <%= render Gustwave::TableHead.new do %>
  #     <tr>
  #       <th>First Name</th>
  #       <th>Last Name</th>
  #     </tr>
  #   <% end %>
  #
  # === Mixed Usage
  #
  # When you mix the two approaches, the +th+ slots will be rendered first,
  # followed by the block content.
  #
  #   <%= render Gustwave::TableHead.new do |thead| %>
  #     <%= thead.th "First Name" %>
  #     <%= thead.th "Last Name" %>
  #     <tr>
  #       <th>First Name</th>
  #       <th>Last Name</th>
  #     </tr>
  #   <% end %>
  class TableHead < Gustwave::Component
    style :scheme,
          default: :standard,
          states: {
            none: "",
            standard: "text-xs text-gray-700 uppercase bg-gray-50 dark:bg-gray-700 dark:text-gray-400"
          }

    renders_many :columns, "Column"
    alias th with_column
    alias column with_column
    alias col with_column

    # @param scheme [Symbol] the styles for the table head. Pass in :none to define your own styles
    # @param options [Hash] additional options for the HTML tag, like class
    def initialize(scheme: :standard, **options)
      @config = configure_html_attributes(
        options,
        class: styles(scheme: scheme)
      )
    end

    def call
      tag.thead **config do
        slots_and_content(column_slots_row)
      end
    end

    private
    attr_reader :config

    def column_slots_row
      tag.tr { safe_join(columns) } if columns?
    end

    class Column < Gustwave::Component
      style :base, "px-6 py-3"

      def initialize(text = nil, **options)
        @text = text
        @config = configure_html_attributes(
          options,
          tag: :th,
          scope: "col",
          class: styles(base: true)
        )
      end

      def call
        render Gustwave::TableCell.new(**config) do
          text_or_content
        end
      end

      private
      attr_reader :text, :config
    end
  end
end
