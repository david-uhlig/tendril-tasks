# frozen_string_literal: true

module DeleteConfirm
  class ModalComponent < TendrilTasks::Component
    attr_reader :id

    # The heading's text, rendered by Modal::ShellComponent
    renders_one :heading, ->(text = t(".title")) { text }

    renders_many :body_elements, types: {
      paragraph: ->(text) {
        Modal::ParagraphComponent.new(text)
      },
      section: ->(&block) {
        block.call
      }
    }

    renders_one :abort_button, ->(text = t(".abort")) do
      Gustwave::Buttons::Default
        .new(color: :light,
             class: "w-full lg:w-auto",
             "data-modal-hide": @id,
             type: :reset)
        .with_content(text)
    end

    renders_one :confirm_button, ->(text = t(".delete_permanently")) do
      Gustwave::Buttons::Default
        .new(type: :submit,
             color: :red,
             class: "w-full lg:w-auto disabled:opacity-50",
             data: { "modal-hide": @id, "cooldown-target": "button" })
        .with_content(tag.span(text, data: { "cooldown-target": "label" }))
    end

    # @param cooldown [Integer] seconds the confirm button stays disabled after
    #   the modal is shown, to prevent accidental clicks. 0 disables it.
    def initialize(id: nil, delete_path:, cooldown: AppConfig.delete_confirm_cooldown)
      @id = id.presence || "delete-confirm-#{SecureRandom.alphanumeric(5)}"
      @delete_path = delete_path
      @cooldown = cooldown.to_i
    end

    def before_render
      with_heading unless heading?
      with_abort_button unless abort_button?
      with_confirm_button unless confirm_button?
    end
  end
end
