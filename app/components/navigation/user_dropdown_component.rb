# frozen_string_literal: true

# Renders a user dropdown menu in the navigation bar.
# It supports dynamic link generation for both regular users and admins.
#
# Example usage:
#
# <%= render(Navigation::UserDropdownComponent.new(user: current_user)) do |dropdown| %>
#   <% dropdown.with_links([
#        { name: "Profile", href: profile_path},
#        { name: "Settings", href: settings_path}]) %>
#   <% dropdown.with_admin_links([
#        { name: "Admin Dashboard", href: admin_dashboard_path }]) %>
# <% end %>
#
# This component defines two sets of links:
# 1. `links`: General links accessible to all users.
# 2. `admin_links`: Links intended for admin users, although access control should be implemented separately.
#
# @param user [User] The current user of the application.
class Navigation::UserDropdownComponent < ViewComponent::Base
  # Renders a collection of regular user links in the dropdown.
  #
  # @param name [String] The display name of the link.
  # @param href [String] The URL the link should point to. Defaults to "#".
  # @yield [block] An optional block to customize the link's content.
  renders_many :links, ->(name: nil, href: "#", &block) do
    render_link name, href, block
  end

  # Renders a collection of admin-specific links in the dropdown.
  # Admin access control logic is still to be implemented.
  #
  # @param name [String] The display name of the link.
  # @param href [String] The URL the link should point to. Defaults to "#".
  # @yield [block] An optional block to customize the link's content.
  renders_many :admin_links, ->(name: nil, href: "#", &block) do
    # TODO: Add admin gate here or in the template to restrict access.
    render_link name, href, block
  end

  # Initializes the component with the given user.
  #
  # @param user [User] The current user of the application.
  def initialize(user:)
    @user = user
  end

  private

  # Renders a link with the provided name, href, and HTML options.
  #
  # @param name [String] The display name of the link.
  # @param href [String] The URL the link should point to.
  # @param block [Proc] An optional block to customize the link's content.
  # @return [String] HTML-safe link tag.
  def render_link(name, href, block)
    html_options = {
      class: "block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white"
    }

    link_to name, href, html_options, &block
  end
end
