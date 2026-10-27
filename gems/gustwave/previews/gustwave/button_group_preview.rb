module Gustwave
  class ButtonGroupPreview < ViewComponent::Preview
    # http://localhost:3030/rails/view_components/gustwave/button_group/default
    def default
      render Gustwave::ButtonGroup.new do |group|
        group.with_button "Profile"
        group.with_button "Settings"
        group.with_button "Messages"
      end
    end

    # http://localhost:3030/rails/view_components/gustwave/button_group/as_links
    def as_links
      render Gustwave::ButtonGroup.new(role: nil) do |group|
        group.with_button "Profile", tag: :a, href: "#", aria: { current: "page" }, class: "text-blue-700"
        group.with_button "Settings", tag: :a, href: "#"
        group.with_button "Messages", tag: :a, href: "#"
      end
    end

    # http://localhost:3030/rails/view_components/gustwave/button_group/with_icons
    def with_icons
      render Gustwave::ButtonGroup.new do |group|
        group.with_button("Profile") { |button| button.with_leading_visual_icon :user_circle, theme: :solid }
        group.with_button("Settings") { |button| button.with_leading_visual_icon :adjustments_vertical }
        group.with_button("Downloads") { |button| button.with_leading_visual_icon :download, theme: :solid }
      end
    end

    # http://localhost:3030/rails/view_components/gustwave/button_group/outline
    def outline
      render Gustwave::ButtonGroup.new(outline: true) do |group|
        group.with_button "Profile"
        group.with_button "Settings"
        group.with_button "Downloads"
      end
    end

    # http://localhost:3030/rails/view_components/gustwave/button_group/outline_with_icons
    def outline_with_icons
      render Gustwave::ButtonGroup.new(outline: true) do |group|
        group.with_button("Profile") { |button| button.with_leading_visual_icon :user_circle, theme: :solid }
        group.with_button("Settings") { |button| button.with_leading_visual_icon :adjustments_vertical }
        group.with_button("Downloads") { |button| button.with_leading_visual_icon :download, theme: :solid }
      end
    end

    # http://localhost:3030/rails/view_components/gustwave/button_group/single_button
    def single_button
      render Gustwave::ButtonGroup.new do |group|
        group.with_button "Profile"
      end
    end

    # The last button keeps its rounded-e-lg, although the tooltip sits after it in the group.
    def with_tooltip
      render_with_template
    end
  end
end
