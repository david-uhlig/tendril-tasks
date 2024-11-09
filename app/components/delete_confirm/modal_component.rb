# frozen_string_literal: true

module DeleteConfirm
  class ModalComponent < ApplicationComponent
    attr_reader :id

    renders_one :heading_slot, ->(text = "Wirklich löschen?") do
      tag.h3 class: "text-xl font-semibold text-gray-900 dark:text-white" do
        text
      end
    end
    alias heading with_heading_slot

    renders_many :texts, ->(text = nil) do
      tag.p class: "text-base leading-relaxed text-gray-500 dark:text-gray-400" do
        text
      end
    end
    alias text with_text

    renders_one :abort_button_slot, ->(text = "Abbrechen") do
      ::ButtonComponent
        .new({ class: "w-full lg:w-auto", "data-modal-hide": @id, type: "reset" }, scheme: :light)
        .with_content(text)
    end
    alias abort_button with_abort_button_slot

    renders_one :confirm_button_slot, ->(text = "Endgültig löschen") do
      ::ButtonComponent
        .new({ class: "w-full lg:w-auto", "data-modal-hide": @id }, scheme: :red)
        .with_content(text)
    end
    alias confirm_button with_confirm_button_slot

    def initialize(id: nil, delete_path:)
      @id = id.presence || "delete-confirm-#{SecureRandom.alphanumeric(5)}"
      @delete_path = delete_path
    end
  end
end
