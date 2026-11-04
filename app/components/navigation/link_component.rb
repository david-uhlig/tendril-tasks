# frozen_string_literal: true

# Renders navigation links with active state handling.
# It can either display block content, a provided name, or the href as the fallback.
#
# Example usage:
#   = render Navigation::LinkComponent.new(name: "Home", href: "/", active: true)
#   = render Navigation::LinkComponent.new(href: "/about") { "About Us" }
#
# Attributes:
# @name [String] The name of the link. Optional. If no block content is provided, this will be displayed.
# @href [String] The URL the link points to. Defaults to "#".
# @active [Boolean] Marks the link as active if `true`. If not provided, the current page check is used.
class Navigation::LinkComponent < TendrilTasks::Component
  # Initializes the link component.
  #
  # @param name [String, nil] The name of the link. If no block content is provided, this will be used.
  # @param href [String] The URL the link points to. Defaults to "#".
  # @param active [Boolean, nil] Whether the link is marked as active. If not provided, it will use the Rails `current_page?` helper to determine if the link is active.
  def initialize(name: nil, href: "#", active: nil)
    @name = name
    @href = href || "#"
    @active = active
  end

  # Renders the link as a Gustwave::Navbars::Link, which sets the active classes and aria-current.
  #
  # @return [String] HTML-safe string of the link element.
  def call
    render Gustwave::Navbars::Link.new(link_label, href: @href, active: active?)
  end

  private

  # Determines if the link should be marked as active.
  #
  # Uses the `@active` value if provided, otherwise falls back to Rails' `current_page?` helper.
  #
  # @return [Boolean] Whether the link is active.
  def active?
    @active || current_page?(@href)
  end

  # Determines what to display as the link label.
  #
  # The method prioritizes the block content, followed by the `@name`, and lastly the `@href`.
  #
  # @return [String] The content to display inside the link.
  def link_label
    content || @name || @href
  end
end
