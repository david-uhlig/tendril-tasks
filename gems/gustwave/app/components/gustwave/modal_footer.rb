# frozen_string_literal: true

module Gustwave
  # Use ModalFooter to render the footer of a Gustwave::Modal
  #
  # === Basic Usage
  #
  #   <%= render Gustwave::Modal.new do |modal| %>
  #     <% modal.with_footer do %>
  #       <button type="button">Yes, I'm sure</button>
  #       <button type="button">No, cancel</button>
  #     <% end %>
  #   <% end %>
  class ModalFooter < Gustwave::Component
    # The gap-3 replaces the ms-3 Flowbite puts on the second button
    base "flex items-center gap-3 p-4 md:p-5 border-t border-gray-200 rounded-b dark:border-gray-600"

    # @param options [Hash] additional options for the HTML tag, like class
    def initialize(**options)
      @options = attributes_for(options)
    end

    def call
      tag.div(**@options) { content }
    end
  end
end
