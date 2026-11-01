module Gustwave
  class DropdownPreview < ViewComponent::Preview
    def default
      render Gustwave::Dropdown.new("Options") do |dropdown|
        dropdown.with_menu_list do |menu|
          menu.with_item_link "Dashboard", href: "#"
          menu.with_item_link "Settings", href: "#", icon: :cog
          menu.with_item_divider
          menu.with_item_link "Sign out", href: "#", icon: :arrow_left_to_bracket
        end
      end
    end

    def with_header_and_footer
      render Gustwave::Dropdown.new("Account", icon: :user_settings) do |dropdown|
        dropdown.with_menu_list do |menu|
          menu.with_header "Signed in as Ada"
          menu.with_item_link "Profile", href: "#"
          menu.with_item_link "Settings", href: "#"
          menu.with_footer "Version 1.0"
        end
      end
    end

    # A submenu takes its label from the block, since a +text+ argument would
    # skip the block that fills the menu.
    def with_submenu
      render_with_template
    end

    def opens_on_hover
      render Gustwave::Dropdown.new("Hover me", trigger_event: :hover) do |dropdown|
        dropdown.with_menu_list do |menu|
          menu.with_item_link "First", href: "#"
          menu.with_item_link "Second", href: "#"
        end
      end
    end

    # The trailing chevron points in the direction of the menu.
    def placements
      render_with_template(locals: { placements: %i[bottom top right left] })
    end

    def inline
      render_with_template
    end

    def custom_trigger
      render_with_template
    end

    def generic_menu
      render_with_template
    end
  end
end
