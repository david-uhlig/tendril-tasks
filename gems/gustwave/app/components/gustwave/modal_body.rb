# frozen_string_literal: true

module Gustwave
  # Use ModalBody to render the body of a Gustwave::Modal
  #
  # === Basic Usage
  #
  #   <%= render Gustwave::Modal.new do |modal| %>
  #     <% modal.with_body do %>
  #       <p>Are you sure you want to delete this item?</p>
  #     <% end %>
  #   <% end %>
  class ModalBody < Gustwave::Component
    base "p-4 md:p-5 space-y-4"

    # @param options [Hash] additional options for the HTML tag, like class
    def initialize(**options)
      @options = attributes_for(options)
    end

    def call
      tag.div(**@options) { content }
    end
  end
end
