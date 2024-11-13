# frozen_string_literal: true

module Form
  module CoordinatorPicker
    # Renders a selectable list of coordinators within an assignment modal.
    #
    # This component uses `SelectionItemComponent` to render individual coordinator items inside an
    # unordered list (`<ul>`). Each item is rendered as a selectable checkbox, making it easy to
    # choose coordinators within a form context.
    #
    # ### Usage:
    # - This component displays a list of coordinator items with hidden checkboxes that are either
    #   checked or unchecked based on the `is_checked` parameter.
    # - Each coordinator item is rendered using the `SelectionItemComponent`, providing a consistent
    #   structure and styling for the list.
    #
    # ### Example:
    # ```ruby
    # <%= render Form::CoordinatorPicker::SelectionComponent.new(id: 'coordinator-list', coordinators: [coordinator1, coordinator2], is_checked: true) %>
    # ```
    #
    # ### Parameters:
    # - `id` (String): A unique identifier for the component's root `<ul>` element.
    # - `coordinators` (Array): A list of coordinators to be displayed in the selection list.
    # - `is_checked` (Boolean): A flag indicating whether all coordinator checkboxes should be initially selected.
    #
    # ### Methods:
    # - `#call`: Renders the `<ul>` element containing each coordinator item in the list.
    #
    # ### Additional Details:
    # - By default, `is_checked` is set to `false`, allowing customization of the list’s initial state.
    # - The list is rendered only if `coordinators` is not empty.
    #
    class SelectionComponent < ApplicationComponent
      def initialize(id, coordinators, is_checked: false)
        @coordinators = coordinators
        @is_checked = is_checked
        @id = id
      end

      def call
        return if @coordinators.empty?

        tag.ul id: @id, class: "flex flex-wrap gap-2 min-rows" do
          @coordinators.each do |coordinator|
            concat render SelectionItemComponent.new(coordinator, is_checked: @is_checked)
          end
        end
      end
    end
  end
end
