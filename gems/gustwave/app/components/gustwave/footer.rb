# frozen_string_literal: true

module Gustwave
  # Use Footer to render the footer at the bottom of a page, as in Flowbite's
  # footers. The footer is a layout wrapper: it renders a +<footer>+ element
  # with a container around the content block. Put the copyright notice,
  # link lists, sitemap groups, brand and social icons in the block, composed
  # from other components.
  #
  # Pass +sticky: true+ to fix the footer to the bottom of the viewport. It
  # then overlays the page, so the page content needs its own bottom offset,
  # as Navbar documents for its top.
  #
  # Use +container_options:+ to set the HTML attributes of the container. Its
  # classes win conflicts with the defaults.
  #
  # Examples:
  #
  # Renders a copyright notice and a row of links:
  #
  #   <%= render Gustwave::Footer.new do %>
  #     <span class="text-sm text-gray-500 sm:text-center dark:text-gray-400">
  #       © 2023 <%= render Gustwave::Link.new("Flowbite", href: "#", color: :none) %>. All Rights Reserved.
  #     </span>
  #     <ul class="flex flex-wrap items-center mt-3 text-sm font-medium text-gray-500 dark:text-gray-400 sm:mt-0">
  #       <li><%= render Gustwave::Link.new("About", href: "#", color: :none, class: "me-4 md:me-6") %></li>
  #       <li><%= render Gustwave::Link.new("Contact", href: "#", color: :none) %></li>
  #     </ul>
  #   <% end %>
  #
  # Renders a sticky footer, fixed to the bottom of the viewport:
  #
  #   <%= render Gustwave::Footer.new(sticky: true) do %>
  #     <span class="text-sm text-gray-500 dark:text-gray-400">© 2023 Flowbite. All Rights Reserved.</span>
  #   <% end %>
  #
  # Renders a rounded footer that floats inside the page, with a card-like
  # outline:
  #
  #   <%= render Gustwave::Footer.new(class: "rounded-lg shadow-sm m-4") do %>
  #     <span class="text-sm text-gray-500 dark:text-gray-400">© 2023 Flowbite. All Rights Reserved.</span>
  #   <% end %>
  #
  # Lays out a second row with +container_options:+, e.g. a row of links
  # beside the copyright notice from the +md+ breakpoint up:
  #
  #   <%= render Gustwave::Footer.new(container_options: { class: "md:flex md:items-center md:justify-between" }) do %>
  #     <span class="text-sm text-gray-500 dark:text-gray-400">© 2023 Flowbite. All Rights Reserved.</span>
  #     <ul class="flex flex-wrap items-center mt-3 text-sm font-medium text-gray-500 dark:text-gray-400 sm:mt-0">
  #       <li><%= render Gustwave::Link.new("Privacy Policy", href: "#", color: :none, class: "me-4 md:me-6") %></li>
  #       <li><%= render Gustwave::Link.new("Contact", href: "#", color: :none) %></li>
  #     </ul>
  #   <% end %>
  #
  # Renders social media icons. An icon-only link needs a visually hidden
  # label, so screen readers can read its name:
  #
  #   <%= render Gustwave::Link.new(href: "#", color: :none, underline: :none, class: "text-gray-500 hover:text-gray-900 dark:hover:text-white") do %>
  #     <%= render Gustwave::Icon.new(:facebook, theme: :solid, class: "w-4 h-4") %>
  #     <span class="sr-only">Facebook page</span>
  #   <% end %>
  #
  # @status alpha
  class Footer < Gustwave::Component
    base "bg-white dark:bg-gray-900"

    part :container, "w-full max-w-screen-xl mx-auto p-4"

    toggle :sticky, "fixed bottom-0 left-0 z-20 w-full border-t border-gray-200 shadow-sm dark:bg-gray-800 dark:border-gray-600"

    # @param sticky [Boolean] whether the footer sticks to the bottom of the viewport. Defaults to +false+.
    # @param container_options [Hash] HTML attributes for the container inside the footer. Its classes win conflicts.
    # @param options [Hash] HTML attributes for the +<footer>+ element.
    def initialize(sticky: false, container_options: {}, **options)
      select_options(sticky:)
      @options = attributes_for(options)
      @container_options = attributes_for(:container, container_options)
    end

    def call
      tag.footer(**@options) { tag.div(content, **@container_options) }
    end
  end
end
