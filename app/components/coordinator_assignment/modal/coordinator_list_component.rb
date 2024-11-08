# frozen_string_literal: true

module CoordinatorAssignment
  module Modal
    # Renders a list of coordinators inside of the assignment modal.
    #
    # It utilizes the `CoordinatorListItemComponent` to render individual coordinators within an
    # unordered list (`<ul>`).
    #
    # ### Usage:
    # - This component can be used to display a list of coordinator items where the underlying checkboxes are all
    # either checked or unchecked depending on `items_checked`.
    # - Each coordinator item is rendered using the `CoordinatorListItemComponent`.
    #
    # ### Example:
    # ```ruby
    # <%= render CoordinatorAssignment::Modal::CoordinatorListComponent.new(id: 'coordinator-list', items_checked: true) do |list| %>
    #   <% list.coordinator Coordinator.new(coordinator1) %>
    #   <% list.coordinator Coordinator.new(coordinator2) %>
    # <% end %>
    # ```
    #
    # ### Parameters:
    # - `id` (String): A unique identifier for the component's root `<ul>` element.
    # - `items_checked` (Boolean): Determines whether coordinators in the list should be marked as "checked".
    #
    # ### Methods:
    # - `#coordinator` alias for `#with_coordinator`: Adds a coordinator item to the list.
    # - `#call`: Renders the `<ul>` element with each coordinator in the list.
    #
    # ### Additional Details:
    # - By default, `items_checked` is set to `false`, but can be overridden to customize the list.
    class CoordinatorListComponent < ApplicationComponent
      renders_many :coordinators, ->(coordinator) do
        CoordinatorListItemComponent.new(
          coordinator,
          is_checked: @items_checked
        )
      end
      alias :coordinator :with_coordinator

      def initialize(id:, items_checked: false)
        @items_checked = items_checked
        @id = id
      end

      def call
        unless coordinators.empty?
          tag.ul id: @id, class: "flex flex-wrap gap-2 min-rows" do
            coordinators.each do |coordinator|
              concat coordinator
            end
          end
        end
      end
    end
  end
end
