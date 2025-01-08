# frozen_string_literal: true

module Form
  module CoordinatorPicker
    # Renders one assigned coordinator.
    #
    # Displays a coordinator card with name, avatar, and a hidden field with the coordinator id.
    class AssigneeItemComponent < TendrilTasks::Component
      def initialize(coordinator = nil)
        @coordinator = coordinator
      end
    end
  end
end
