# frozen_string_literal: true

module Gustwave
  # Use TableCaption to render an HTML caption element
  #
  # The +title+ and +description+ slots provide default styling for the caption.
  # Alternatively, you can pass in a block that gets appended to any slots. Both
  # slots take a simplified +text+ argument or a block.
  #
  # === Basic Usage
  #
  # Use the simplified text argument or supply a block to the +title+ and
  # +description+ slots.
  #
  #   <%= render Gustwave::TableCaption.new do |caption| %>
  #     <% caption.title "Table Title" %>
  #     <% caption.description do %>
  # 	    Description text
  #     <% end %>
  #   <% end %>
  #
  # === Usage with Block
  #
  # Alternatively, you can pass in a block to the +TableCaption+ component.
  #
  #   <%= render Gustwave::TableCaption.new do %>
  #     <h2>Table Title</h2>
  #     <p>Description text</p>
  #   <% end %>
  #
  # === Custom Styling
  #
  # You can provide your own styling:
  #   <%= render Gustwave::TableCaption.new(scheme: :none, class: "bg-white") do %>
  # 	  <h2>Table Title</h2>
  # 	  <p>Description text</p>
  #   <% end %>
  class TableCaption < Gustwave::Component
    style :scheme,
          default: :standard,
          states: {
            none: "",
            standard: "p-5 text-lg font-semibold text-left rtl:text-right text-gray-900 bg-white dark:text-white dark:bg-gray-800"
          }

    renders_one :title_slot, ->(text = nil, &block) {
      text || block.call
    }
    alias title with_title_slot

    renders_one :description_slot, ->(text = nil, **options, &block) {
      config = configure_html_attributes(
        options,
        class: "mt-1 text-sm font-normal text-gray-500 dark:text-gray-400"
      )

      tag.p **config do
        text || block.call
      end
    }
    alias description with_description_slot

    # @param scheme [Symbol] the styles for the table caption. Pass in :none to define your own styles.
    # @param options [Hash] additional options for the HTML tag, like class.
    def initialize(scheme: :standard, **options)
      @config = configure_html_attributes(
        options,
        class: styles(scheme: scheme)
      )
    end

    def call
      tag.caption **config do
        slots_and_content(title_slot, description_slot)
      end
    end

    private
    attr_reader :config
  end
end
