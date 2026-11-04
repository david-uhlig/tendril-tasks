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
  #
  # @status alpha
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
        safe_join([ title_tag, (close_button if @close_button) ].compact)
      end
    end

    # The button rendered when no +close_button+ is set. Public, because
    # ViewComponent only finds +default_<slot>+ methods that are public.
    def default_close_button
      build_slot_close_button
    end

    # Hides the modal when clicked. The close button is rendered by default,
    # see +close_button:+ to hide it.
    #
    # @param text [String, nil] text to display to screen readers. Defaults to a localized "Close".
    # @param icon [Symbol] The icon to use for the close button. Defaults to +:close+.
    # @param options [Hash] Additional HTML options passed to the button component. Its +class+ adds to the button's classes.
    renders_one_extensible :close_button, ->(text = nil, icon: :close, **options) {
      # Accepts +text:+ too, as a keyword, since the lambda's positional
      # argument can't take it.
      text ||= options.delete(:text)

      button = Gustwave::Button.for(:inline).new(
        sr_only(text.presence || t(".close")),
        **configure_html_attributes(options,
                                    color: :none,
                                    class: "text-gray-400 bg-transparent hover:bg-gray-200 hover:text-gray-900 rounded-lg text-sm w-8 h-8 ms-auto inline-flex justify-center items-center dark:hover:bg-gray-600 dark:hover:text-white",
                                    **Gustwave::Modal.trigger_options(@modal_id, action: :hide))
      )
      # Gustwave's icons draw within the middle half of their box, so this
      # matches Flowbite's w-3 h-3 close icon
      button.with_leading_visual_icon(icon, stroke_width: 2, class: "w-6 h-6")
      button
    }

    private

    attr_reader :text

    def title_tag
      options = @title_options.merge(class: class_names("font-semibold", @title_options[:class]))
      render Gustwave::Heading.new(text_or_content(text), tag: :h3, size: :xs, id: "#{@modal_id}-title", **options)
    end
  end
end
