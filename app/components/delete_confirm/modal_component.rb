# frozen_string_literal: true

module DeleteConfirm
  class ModalComponent < TendrilTasks::Component
    attr_reader :id

    renders_one :heading_slot, ->(text = t(".title")) do
      tag.h3 class: "text-xl font-semibold text-gray-900 dark:text-white" do
        text
      end
    end
    alias heading with_heading_slot

    renders_many :body_elements, types: {
      paragraph: ->(text) {
        tag.p text, class: "text-base leading-relaxed text-gray-500 dark:text-gray-400"
      },
      element: ->(&block) {
        block.call
      }
    }
    alias paragraph with_body_element_paragraph
    alias element with_body_element_element
    alias section with_body_element_element

    renders_one :abort_button_slot, ->(text = t(".abort")) do
      Gustwave::Button
        .new(scheme: :light,
             class: "w-full lg:w-auto",
             "data-modal-hide": @id,
             type: :reset)
        .with_content(text)
    end
    alias abort_button with_abort_button_slot

    renders_one :confirm_button_slot, ->(text = t(".delete_permanently")) do
      Gustwave::Button
        .new(type: :submit,
             scheme: :red,
             class: "w-full lg:w-auto",
             data: { "modal-hide": @id })
        .with_content(text)
    end
    alias confirm_button with_confirm_button_slot

    def initialize(id: nil, delete_path:)
      @id = id.presence || "delete-confirm-#{SecureRandom.alphanumeric(5)}"
      @delete_path = delete_path
    end
  end
end
