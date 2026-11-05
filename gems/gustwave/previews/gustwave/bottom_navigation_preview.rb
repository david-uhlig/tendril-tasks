module Gustwave
  class BottomNavigationPreview < ViewComponent::Preview
    # Four buttons with icons and labels under them, fixed to the bottom of the viewport.
    def default
      render_with_template
    end

    # The items are separated by lines, as in Flowbite's border example.
    def border
      render_with_template
    end

    # A rounded bar floating above the bottom edge. Its centre item is a call to action, with its label as a tooltip.
    def application_bar
      render_with_template
    end

    # A pager in the middle of the bar, with page controls, between two buttons on each side. Six columns.
    def pagination
      render_with_template
    end

    # A segmented control above the items. The items show their labels as tooltips.
    def button_group
      render_with_template
    end

    # The bar sticks to the bottom of a scrolling card instead of the viewport.
    def card
      render_with_template
    end

    # No items: the whole bar is block content, with the controls of an online meeting.
    def meeting_controls
      render_with_template
    end

    # No items: the bar is a player with a progress bar, taller than the others.
    def video_player
      render_with_template
    end

    # The placement, the floating shape, the lines and the label display can all be changed here.
    # @param position select { choices: [fixed, sticky, none] }
    # @param floating toggle
    # @param bordered toggle
    # @param label_display select { choices: [inside, tooltip] }
    def playground(position: :fixed, floating: false, bordered: false, label_display: :inside)
      render_with_template(locals: { position: position.to_sym, floating:, bordered:, label_display: label_display.to_sym })
    end
  end
end
