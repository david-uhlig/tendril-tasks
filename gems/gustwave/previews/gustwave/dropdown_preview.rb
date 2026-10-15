module Gustwave
  class DropdownPreview < ViewComponent::Preview
    # http://localhost:3030/rails/view_components/gustwave/dropdown/default
    def default
      render Gustwave::Dropdown.new("Options") do |dropdown|
        dropdown.menu do |menu|
          menu.item "Dashboard", href: "#"
          menu.item "Settings", href: "#", icon: :cog
          menu.divider
          menu.item "Sign out", href: "#", icon: :arrow_left_to_bracket
        end
      end
    end

    def with_header_and_footer
      render Gustwave::Dropdown.new("Account", icon: :user_settings) do |dropdown|
        dropdown.menu do |menu|
          menu.header "Signed in as Ada"
          menu.item "Profile", href: "#"
          menu.item "Settings", href: "#"
          menu.footer "Version 1.0"
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
        dropdown.menu do |menu|
          menu.item "First", href: "#"
          menu.item "Second", href: "#"
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
