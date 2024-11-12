# frozen_string_literal: true

module CoordinatorAssignment
  # Renders a button that toggles the `CoordinatorAssignment::ModalComponent` visibility.
  class EditButtonComponent < ApplicationComponent
    def initialize(text: "Ansprechpersonen bearbeiten")
      @text = text
    end

    def call
      render ButtonComponent.new(
        scheme: :alternative,
        id: "edit-coordinator-assignment",
        data: {
          "modal-target": "coordinator-search-modal",
          "modal-show": "coordinator-search-modal"
        },
        class: "w-full",
        type: "button").with_content(@text)
    end
  end
end
