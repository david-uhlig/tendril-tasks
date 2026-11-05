module Gustwave
  class ListGroupPreview < ViewComponent::Preview
    # Text items in a ul, as in Flowbite's default list group. The width comes from the caller.
    # http://localhost:3030/rails/view_components/gustwave/list_group/default
    def default
      render Gustwave::ListGroup.new(class: "w-48") do |list_group|
        list_group.with_item_text("Profile")
        list_group.with_item_text("Settings")
        list_group.with_item_text("Messages")
        list_group.with_item_text("Download")
      end
    end

    # Links, with the first one active and marked as the current item. The list renders as a div.
    # http://localhost:3030/rails/view_components/gustwave/list_group/links
    def links
      render Gustwave::ListGroup.new(class: "w-48") do |list_group|
        list_group.with_item_link("Profile", href: "#", active: true)
        list_group.with_item_link("Settings", href: "#")
        list_group.with_item_link("Messages", href: "#")
        list_group.with_item_link("Download", href: "#")
      end
    end

    # Buttons, with the first one active and the last one disabled.
    # http://localhost:3030/rails/view_components/gustwave/list_group/buttons
    def buttons
      render Gustwave::ListGroup.new(class: "w-48") do |list_group|
        list_group.with_item_button("Profile", active: true)
        list_group.with_item_button("Settings")
        list_group.with_item_button("Messages")
        list_group.with_item_button("Download", disabled: true)
      end
    end

    # Buttons with an icon before the text, as a menu.
    # http://localhost:3030/rails/view_components/gustwave/list_group/icons
    def icons
      render Gustwave::ListGroup.new(class: "w-48") do |list_group|
        list_group.with_item_button("Profile", icon: :user_circle)
        list_group.with_item_button("Settings", icon: :cog)
        list_group.with_item_button("Messages", icon: :envelope)
        list_group.with_item_button("Download", icon: :download)
      end
    end
  end
end
