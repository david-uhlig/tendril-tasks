# frozen_string_literal: true

module Modal
  # Use ShellComponent to render the frame of a Flowbite modal: the backdrop
  # container, the content box and a header with a heading and a close button.
  #
  # The block's content, apart from the heading, is rendered below the header,
  # e.g. the modal's body and footer.
  #
  #   <%= render Modal::ShellComponent.new("confirm-dialog") do |shell| %>
  #     <% shell.heading t(".title") %>
  #
  #     <div class="p-4 md:p-5">…</div>
  #   <% end %>
  #
  # Open the modal with a toggle carrying +data-modal-target+ and
  # +data-modal-show+ set to the modal's +id+.
  #
  # @param id [String] the modal's id, targeted by its toggles.
  # @param options [Hash] HTML attributes passed to the +section+ element. Data
  #   attributes are merged with the modal's own.
  class ShellComponent < TendrilTasks::Component
    HEADING_CLASS = "text-xl font-semibold text-gray-900 dark:text-white"
    # Classes for the modal's footer, rendered by the caller below the body
    FOOTER_CLASS = "grid grid-cols-1 place-items-stretch gap-2 p-4 md:p-5 border-t border-gray-200 rounded-b dark:border-gray-600"

    attr_reader :id

    # Use the +heading+ slot for the modal's title, passed as an argument or a block.
    #
    # @param text [String] the title, unless given as a block.
    # @param options [Hash] HTML attributes passed to the +h3+ element.
    renders_one :heading_slot, ->(text = nil, **options, &block) do
      options.symbolize_keys!
      options[:class] = class_merge(HEADING_CLASS, options.delete(:class))
      tag.h3(block ? capture(&block) : text, **options)
    end
    alias heading with_heading_slot

    def initialize(id, **options)
      @id = id

      options.deep_symbolize_keys!
      options[:data] = { "modal-backdrop": "static" }.merge(options.fetch(:data, {}))
      @options = options
    end
  end
end
