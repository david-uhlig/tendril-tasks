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
  # Build an icon key with +with_icon+. The label is for screen readers only:
  #
  #   <%= render Gustwave::Kbd.new do |kbd| %>
  #     <% kbd.with_icon(:caret_up, label: "Arrow key up") %>
  #   <% end %>
  #
  # Mirror the left and right arrows for right-to-left text:
  #
  #   <%= render Gustwave::Kbd.new(class: "rtl:rotate-180") do |kbd| %>
  #     <% kbd.with_icon(:caret_right, label: "Arrow key right") %>
  #   <% end %>
  #
  # Renders leading and trailing visuals, see Gustwave::Visuals. Unlike
  # +with_icon+, these don't add a label.
  #
  # You can pass HTML attributes to the +<kbd>+ element and your css classes
  # will be merged with the default classes without style conflicts.
  #
  # @status alpha
  class Kbd < Gustwave::Component
    include Gustwave::Visuals

    base "px-2 py-1.5 text-xs font-semibold text-gray-800 bg-gray-100 border border-gray-200 rounded-lg " \
         "dark:bg-gray-600 dark:text-gray-100 dark:border-gray-500"

    # Gustwave::Visuals needs a size. Keys have one. Gustwave's icons leave a
    # blank margin around their drawing, so the 16px icon takes a negative
    # margin of 3px on each side, which leaves the 10px layout box of
    # Flowbite's arrows.
    variant :size, default: :xs, internal: true, values: {
      xs: { root: "", visual: "h-4 w-4 -m-0.75" }
    }

    derive :indicator_size, from: :size, values: { xs: :sm }

    def initialize(text = nil, **options)
      @text = text
      @icon_labels = []
      @options = options
    end

    # Adds a leading icon and its screen reader label.
    #
    # @param name [Symbol] the icon's name.
    # @param label [String] the text for screen readers.
    # @param theme [Symbol] the icon's theme. Defaults to +:solid+.
    # @param options [Hash] additional options for the icon.
    # @return [Gustwave::Kbd] self
    def with_icon(name, label:, theme: :solid, **options)
      with_leading_visual_icon(name, theme:, **options)
      @icon_labels << label
      self
    end

    def before_render
      # Reading the slots runs the block, which sets the icon labels.
      select_options(has_visual: has_visual?)
      @config = attributes_for(@options)
    end

    def call
      tag.kbd(
        slots_and_content(leading_visuals, icon_labels, text_or_content(text), trailing_visuals, append_content: false),
        **@config
      )
    end

    private

    attr_reader :text

    def icon_labels
      safe_join(@icon_labels.map { |label| tag.span(label, class: "sr-only") })
    end
  end
end
