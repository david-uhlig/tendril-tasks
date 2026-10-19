# frozen_string_literal: true

module TendrilTasks
  # Use `Breadcrumb` to display page hierarchy.
  #
  # This component allows you to render a breadcrumb navigation with a home link
  # and multiple breadcrumb items.
  #
  # === Rendering a breadcrumb navigation
  #
  # This example renders a breadcrumb navigation with a home link and two
  # breadcrumb items.
  #
  #   <%= render TendrilTasks::Breadcrumb.new do |breadcrumb| %>
  #     <% breadcrumb.with_home "Home", href: root_path, icon: :home %>
  #     <% breadcrumb.with_item "Section", href: section_path %>
  #     <% breadcrumb.with_item "Subsection", href: subsection_path %>
  #   <% end %>
  class Breadcrumb < TendrilTasks::Component
    # Renders a single home link slot.
    #
    # @param title [String] the title of the home link (default: the home title in the current locale)
    # @param href [String] the URL for the home link (default: root_path)
    # @param icon [Symbol] the icon for the home link (default: :home)
    #
    # @return [TendrilTasks::BreadcrumbItem] the home link item
    renders_one :home, ->(title = nil, href: root_path, icon: :home) {
      TendrilTasks::BreadcrumbItem.new(title || t(".home"), href: href, icon: icon)
    }

    # Renders multiple breadcrumb items.
    #
    # @return [Array<TendrilTasks::BreadcrumbItem>] the breadcrumb items
    renders_many :items, TendrilTasks::BreadcrumbItem
  end
end
