# frozen_string_literal: true

module CoordinatorAssignment
  # Renders a list of assigned coordinators. The assignment "target" depends on the enclosing context,
  # e.g. a task or a project.
  #
  # The list is immutable. It can only be changed by user input through the CoordinatorAssignment::ModalComponent.
  class AssignedListComponent < ApplicationComponent
    renders_many :coordinators, AssignedListItemComponent
    alias :coordinator :with_coordinator

    def call
      unless coordinators.empty?
        tag.ul id: "selected-coordinators", class: "grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-2" do
          coordinators.each do |coordinator|
            concat coordinator
          end
        end
      end
    end
  end
end
