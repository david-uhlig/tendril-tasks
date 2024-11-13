# frozen_string_literal: true

module Form
  module CoordinatorPicker
    # Renders a modal to assign, unassign and search for coordinators.
    class ModalComponent < ApplicationComponent
      ID = "coordinator-picker-modal"

      def initialize(assigned:, suggestions:)
        @assigned = assigned
        @suggestions = suggestions
        @id = ID
      end
    end
  end
end
