module Gustwave
  class NavbarPreview < ViewComponent::Preview
    def default
      render_with_template
    end

    # A call to action in the actions row, next to the hamburger toggle.
    def with_actions
      render_with_template
    end

    # The navbar is fixed to the top of the viewport and overlays the page, so
    # the page content needs its own top offset.
    def sticky
      render_with_template
    end

    def solid
      render_with_template
    end

    # A dropdown is not a link, so it goes in a generic item. The dropdown's
    # trigger is inline text with the classes of an inactive link, so it lines
    # up with the links next to it, also as a row in the collapsed menu.
    def with_dropdown
      render_with_template
    end

    # Smaller text than +with_dropdown+.
    def with_compact_dropdown
      render_with_template
    end

    # A dropdown with a submenu inside its menu.
    def with_multi_level_dropdown
      render_with_template
    end

    # A second row of links below the navbar.
    def with_submenu
      render_with_template
    end

    # A language switcher with flags in the actions row.
    def with_language_dropdown
      render_with_template
    end

    # A user avatar that opens a user menu in the actions row.
    def with_user_menu
      render_with_template
    end

    # A search field beside the actions on desktop. On mobile, a search button
    # in the actions opens the menu, where the field is the first item. So the
    # mobile search is a list item in the menu rather than a block before the list.
    def with_search
      render_with_template
    end
  end
end
