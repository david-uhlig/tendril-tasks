# frozen_string_literal: true

module Gustwave
  # Use TableBody to render an HTML tbody element
  #
  # \Table rows can be provided through slots or by passing in block content.
  # The +tr+ slots (alias +row+) render a +<tr>+ HTML element. Block content
  # gets appended at the end of any provided rows.
  #
  # === Basic Usage
  #
  # Use the +tr+ slot to pass in table rows.
  #
  #   <%= render Gustwave::TableBody.new do |tbody| %>
  #     <% tbody.tr do %>
  #       <td>First Name</td>
  #       <td>Last Name</td>
  #     <% end %>
  #   <% end %>
  #
  # === Usage with Block
  #
  # Alternatively, you can pass in block content.
  #
  #   <%= render Gustwave::TableBody.new do %>
  #     <tr>
  #       <td>First Name</td>
  #       <td>Last Name</td>
  #     </tr>
  #   <% end %>
  class TableBody < Gustwave::Component
    renders_many :rows, Gustwave::TableRow
    alias row with_row
    alias tr with_row

    # @param options [Hash] additional options for the HTML tag, like class
    def initialize(**options)
      @config = configure_html_attributes(options)
    end

    def call
      tag.tbody **config do
        slots_and_content(rows)
      end
    end

    private
    attr_reader :config
  end
end
