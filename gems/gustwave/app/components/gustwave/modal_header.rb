# frozen_string_literal: true

module Gustwave
  # Use ModalHeader to render the header of a Gustwave::Modal. The title is an
  # h3 with the id the modal's +aria-labelledby+ points at.
  #
  # === Basic Usage
  #
  #   <%= render Gustwave::Modal.new do |modal| %>
  #     <% modal.with_header("Delete task") %>
  #   <% end %>
  #
  # Standalone, pass +modal_id+ and, to hide the close button, +close_button: false+:
  #
  #   <%= render Gustwave::ModalHeader.new("Delete task", modal_id: "delete-task", close_button: false) %>
  class ModalHeader < Gustwave::Component
    base "flex items-center justify-between p-4 md:p-5 border-b border-gray-200 rounded-t dark:border-gray-600"

    # @param text [String, nil] The title. Takes precedence over block content.
    # @param modal_id [String] The id of the modal, which the title and the close button refer to.
    # @param close_button [Boolean] Whether to render the close button. Set by Gustwave::Modal from its +dismissible+ option; pass it yourself when rendering the header standalone. Defaults to +true+.
    # @param title_options [Hash] Options for the title, a Gustwave::Heading, e.g. +class+.
    # @param options [Hash] Additional HTML attributes for the root element.
    def initialize(text = nil, modal_id:, close_button: true, title_options: {}, **options)
      @text = text
      @modal_id = modal_id
      @close_button = ActiveModel::Type::Boolean.new.cast(close_button) != false
      @title_options = title_options
      @config = attributes_for(options)
    end

    def call
      tag.div(**@config) do
        safe_join([ title_tag, close_button ].compact)
      end
    end

    private

    attr_reader :text

    def title_tag
      render Gustwave::Heading.new(text_or_content(text), tag: :h3, size: :xs, id: "#{@modal_id}-title", **@title_options)
    end

    def close_button
      return unless @close_button

      button = Gustwave::Button.for(:inline).new(
        sr_only(t(".close")),
        color: :none,
        class: "text-gray-400 bg-transparent hover:bg-gray-200 hover:text-gray-900 rounded-lg text-sm w-8 h-8 ms-auto inline-flex justify-center items-center dark:hover:bg-gray-600 dark:hover:text-white",
        **Gustwave::Modal.trigger_options(@modal_id, action: :hide)
      )
      # Gustwave's icons draw within the middle half of their box, so this
      # matches Flowbite's w-3 h-3 close icon
      button.with_leading_visual_icon(:close, stroke_width: 2, class: "w-6 h-6")
      render button
    end
  end
end
