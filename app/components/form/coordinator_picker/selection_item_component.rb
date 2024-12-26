# frozen_string_literal: true

module Form
  module CoordinatorPicker
    # Renders a coordinator item in a list, typically used within a modal context.
    # This component displays the coordinator's name, avatar, and a checkbox. The checkbox is hidden, but can be
    # interacted with through the keyboard or mouse interaction.
    #
    # ### Usage:
    # - Used to render an individual coordinator item.
    # - This component can be rendered within a parent component like `SelectionComponent`.
    #
    # ### Example:
    # ```ruby
    # <%= render Form::CoordinatorPicker::SelectionItemComponent.new(coordinator, is_checked: true) %>
    # ```
    #
    # ### Parameters:
    # - `coordinator` (Object): The coordinator to be displayed, expected to have attributes like `id`, `name`, and `avatar_url`.
    # - `is_checked` (Boolean): Determines if the checkbox for the coordinator is selected initially.
    #
    # ### Additional Details:
    # - `id`: The checkbox ID is dynamically generated based on the coordinator's ID to ensure unique accessibility.
    # - `data-action`: The checkbox has a `data-action` attribute for handling changes (e.g., `list-mover#toggle`).
    # - `peer` CSS classes are used for styling interactions when the checkbox is focused or selected.
    class SelectionItemComponent < TendrilTasks::Component
      def initialize(coordinator, is_checked: false)
        @coordinator = coordinator
        @is_checked = is_checked
      end
    end
  end
end
