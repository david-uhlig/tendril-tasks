# frozen_string_literal: true

module CoordinatorAssignment
  # Renders one assigned coordinator.
  #
  # Displays a coordinator card with name, avatar, and a hidden field with the coordinator id.
  class AssignedListItemComponent < ApplicationComponent
    def initialize(coordinator = nil)
      @coordinator = coordinator
    end
  end
end
