# frozen_string_literal: true

module Form
  module CoordinatorPicker
    # Renders a list of assigned coordinators. The assignment "target" depends on the enclosing context,
    # e.g. a task or a project.
    #
    # The list is immutable. It can only be changed by user input through the CoordinatorAssignment::ModalComponent.
    class AssigneeComponent < ApplicationComponent
      def initialize(assignees)
        @assignees = assignees
      end

      def call
        unless @assignees.empty?
          tag.ul id: "selected-coordinators", class: "grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-2 mb-3" do
            @assignees.each do |coordinator|
              concat render AssigneeItemComponent.new(coordinator)
            end
          end
        end
      end
    end
  end
end
