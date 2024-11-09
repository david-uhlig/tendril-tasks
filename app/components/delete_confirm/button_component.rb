# frozen_string_literal: true

module DeleteConfirm
  class ButtonComponent < ApplicationComponent
    attr_reader :target_modal_id

    def initialize(text:, target_modal_id: nil)
      @text = text
      @target_modal_id = target_modal_id.presence || "delete-confirm-#{SecureRandom.alphanumeric(5)}"
    end

    def call
      render ::ButtonComponent
        .new({ class: "w-full",
               "data-modal-target": @target_modal_id,
               "data-modal-toggle": @target_modal_id,
               type: "button"
             }, scheme: :red, size: :large)
        .with_content(@text)
    end
  end
end
