# frozen_string_literal: true

module TendrilTasks
  # Displays page hierarchy.
  #
  # This component allows you to render a breadcrumb navigation with a home link
  # and multiple breadcrumb items.
  #
  # @example Rendering a breadcrumb navigation
  #
  #   <%= render TendrilTasks::Breadcrumb.new do |breadcrumb| %>
  #     <% breadcrumb.home "Home", href: root_path, icon: :home %>
  #     <% breadcrumb.item "Section", href: section_path %>
  #     <% breadcrumb.item "Subsection", href: subsection_path %>
  #   <% end %>
  #
  class Breadcrumb < TendrilTasks::Component
    # Default title for the home link.
    DEFAULT_HOME_TITLE = t(".home")

    # Renders a single home link slot.
    #
    # @param title [String] the title of the home link (default: DEFAULT_HOME_TITLE)
    # @param href [String] the URL for the home link (default: root_path)
    # @param icon [Symbol] the icon for the home link (default: :home)
    #
    # @return [TendrilTasks::BreadcrumbItem] the home link item
    renders_one :home_slot, ->(title = DEFAULT_HOME_TITLE, href: root_path, icon: :home) {
      TendrilTasks::BreadcrumbItem.new(title, href: href, icon: icon)
    }
    alias home with_home_slot

    # Renders multiple breadcrumb items.
    #
    # @return [Array<TendrilTasks::BreadcrumbItem>] the breadcrumb items
    renders_many :items, TendrilTasks::BreadcrumbItem
    alias item with_item
  end
end
