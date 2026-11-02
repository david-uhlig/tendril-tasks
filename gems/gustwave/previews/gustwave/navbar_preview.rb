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

    # Smaller text than +with_dropdown+, as in the example on Flowbite's dropdown page.
    def with_compact_dropdown
      render_with_template
    end

    # A dropdown with a submenu inside its menu, as in Flowbite's multi-level dropdown example.
    def with_multi_level_dropdown
      render_with_template
    end

    # A second row of links below the navbar, as in Flowbite's navbar with submenu example.
    def with_submenu
      render_with_template
    end

    # A language switcher with a globe icon in the actions row, as in Flowbite's language dropdown example.
    def with_language_dropdown
      render_with_template
    end

    # A user avatar that opens a user menu in the actions row, as in Flowbite's user menu example.
    def with_user_menu
      render_with_template
    end
  end
end
