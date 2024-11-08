# frozen_string_literal: true

module CoordinatorAssignment
  # Renders a modal to assign, unassign and search for coordinators.
  class ModalComponent < ApplicationComponent
    def initialize(selected:, options:)
      @selected = selected
      @options = options
    end
  end
end
