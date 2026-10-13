# frozen_string_literal: true

module Gustwave
  # Use Table to render an HTML table element
  #
  # \Table +caption+, +thead+, and +tbody+ can be provided through slots or by passing
  # in block content.
  # * The +caption+ slot renders a +<caption>+ HTML element
  # * The +head+ slot renders a +<thead>+ HTML element
  # * The +body+ slot renders a +<tbody>+ HTML element
  #
  # Block content gets appended at the end of any provided slots.
  #
  # TODO implement foot slot
  class Table < Gustwave::Component
    style :scheme,
          default: :standard,
          states: {
            none: "",
            standard: "w-full text-sm text-left rtl:text-right text-gray-500 dark:text-gray-400"
          }

    renders_one :caption_slot, Gustwave::TableCaption
    alias caption with_caption_slot

    renders_one :head_slot, Gustwave::TableHead
    alias head with_head_slot
    alias thead with_head_slot

    renders_one :body_slot, Gustwave::TableBody
    alias body with_body_slot
    alias tbody with_body_slot

    # @param scheme [Symbol] the styles for the table. Pass in :none to define your own styles.
    # @param options [Hash] additional options for the HTML tag.
    def initialize(scheme: :standard, **options)
      @config = configure_html_attributes(
        options,
        class: styles(scheme: scheme)
      )
    end

    def call
      tag.table **config do
        slots_and_content(caption_slot, head_slot, body_slot)
      end
    end

    private
    attr_reader :config
  end
end
