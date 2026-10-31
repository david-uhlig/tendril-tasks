# frozen_string_literal: true

module Modal
  # Use ShellComponent to render a modal with a static backdrop. The modal is
  # a Gustwave::Modal, which adds the focus trap and the header with the close
  # button.
  #
  # The block's content, apart from the heading, is rendered below the header,
  # e.g. the modal's body and footer.
  #
  #   <%= render Modal::ShellComponent.new("confirm-dialog") do |shell| %>
  #     <% shell.with_heading t(".title") %>
  #
  #     <div class="p-4 md:p-5">…</div>
  #   <% end %>
  #
  # Open the modal with a trigger from +Gustwave::Modal.trigger_options(id)+.
  #
  # @param id [String] the modal's id, targeted by its toggles.
  # @param options [Hash] HTML attributes passed to the modal's root element.
  class ShellComponent < TendrilTasks::Component
    attr_reader :id

    # Use the +heading+ slot for the modal's title, passed as an argument or a block.
    #
    # @param text [String] the title, unless given as a block.
    # @param options [Hash] options for the title, passed as +title_options+ to the header.
    renders_one :heading, ->(text = nil, **options, &block) do
      @heading_text = block ? capture(&block) : text
      @heading_options = options
      @heading_text
    end

    def initialize(id, **options)
      @id = id
      @options = options
    end
  end
end
