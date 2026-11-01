# frozen_string_literal: true

module Gustwave
  # Use Kbd to render a keyboard key in a +<kbd>+ element.
  #
  # Examples:
  #
  # Renders a key from the text argument
  #
  #   <%= render Gustwave::Kbd.new("Shift") %>
  #
  # Pass a wider key by adding padding, e.g. for the space bar:
  #
  #   <%= render Gustwave::Kbd.new("Space", class: "px-4") %>
  #
  # Build an icon key from an icon and a screen reader label. The +has-[svg]:+
  # classes give keys that contain an icon Flowbite's +inline-flex items-center+
  # layout, and tighter padding that keeps a +:xs+ icon's key close to the size
  # of Flowbite's:
  #
  #   <%= render Gustwave::Kbd.new do %>
  #     <%= render Gustwave::Icon.new(:caret_up, theme: :solid, size: :xs, aria: { hidden: true }) %>
  #     <span class="sr-only">Arrow key up</span>
  #   <% end %>
  #
  # Mirror the left and right arrows for right-to-left text:
  #
  #   <%= render Gustwave::Kbd.new(class: "rtl:rotate-180") do %>
  #     <%= render Gustwave::Icon.new(:caret_right, theme: :solid, size: :xs, aria: { hidden: true }) %>
  #     <span class="sr-only">Arrow key right</span>
  #   <% end %>
  #
  # You can pass HTML attributes to the +<kbd>+ element and your css classes
  # will be merged with the default classes without style conflicts.
  #
  class Kbd < Gustwave::Component
    base "px-2 py-1.5 text-xs font-semibold text-gray-800 bg-gray-100 border border-gray-200 rounded-lg " \
         "has-[svg]:inline-flex has-[svg]:items-center has-[svg]:px-1 has-[svg]:py-0.5 " \
         "dark:bg-gray-600 dark:text-gray-100 dark:border-gray-500"

    def initialize(text = nil, **options)
      @text = text
      @options = attributes_for(options)
    end

    def call
      tag.kbd(text_or_content(text), **@options)
    end

    private

    attr_reader :text
  end
end
