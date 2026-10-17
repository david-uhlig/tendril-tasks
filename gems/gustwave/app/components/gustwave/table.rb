# frozen_string_literal: true

module Gustwave
  # Use Table to render an HTML table element
  #
  # \Table +caption+, +head+, and +body+ can be provided through slots or by passing
  # in block content.
  # * The +caption+ slot renders a +<caption>+ HTML element
  # * The +head+ slot renders a +<thead>+ HTML element
  # * The +body+ slot renders a +<tbody>+ HTML element
  #
  # Block content gets appended at the end of any provided slots.
  #
  # TODO implement foot slot
  class Table < Gustwave::Component
    base "w-full text-sm text-left rtl:text-right text-gray-500 dark:text-gray-400"

    renders_one_extensible :caption, Gustwave::TableCaption

    renders_one_extensible :head, Gustwave::TableHead

    renders_one_extensible :body, Gustwave::TableBody

    # @param options [Hash] additional options for the HTML tag.
    def initialize(**options)
      @config = attributes_for(options)
    end

    def call
      tag.table **config do
        slots_and_content(caption, head, body)
      end
    end

    private
    attr_reader :config
  end
end
