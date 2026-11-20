# frozen_string_literal: true

module Gustwave
  module Form
    module InputGroups
      # Use Button to render the grey addon button of a
      # Gustwave::Form::InputGroup, registered as the +:input_addon+ theme of
      # Gustwave::Button. It is the button of the group's dropdown addon. The
      # group's addon buttons use the +:default+ theme instead: pass
      # <tt>theme: :input_addon</tt> for this look. Any other theme and its
      # options work too. The group sets the +side+ and +size+. The button
      # drops the border of the side facing the control, so the control's
      # border, and with it its validation color, stays whole.
      #
      #   <%= render Gustwave::Form::InputGroup.new do |group| %>
      #     <% group.with_leading_addon_button("All categories", theme: :input_addon) %>
      #     <% group.with_control_input(name: "q", type: :search) %>
      #   <% end %>
      #
      # @status alpha
      class Button < Gustwave::Buttons::Base
        # Replaces Base's rounded-lg focus:ring-4. The gap and the chevron's
        # margin sum to Flowbite's chevron spacing.
        base "shrink-0 z-10 inline-flex items-center text-center whitespace-nowrap font-medium focus:outline-hidden focus:ring-4 disabled:cursor-not-allowed", unless: { color: :none }

        extend_variant :color, default: :default, values: {
          default: "text-gray-900 bg-gray-100 border-gray-300 hover:bg-gray-200 focus:ring-gray-100 dark:bg-gray-700 dark:hover:bg-gray-600 dark:focus:ring-gray-700 dark:text-white dark:border-gray-600"
        }

        # The padding and text size per size of the group. The group's height
        # comes from the taller of the button and the control.
        variant :size, default: :md, values: {
          sm: { root: "px-3 py-2 text-xs gap-1.5", visual: "h-4 w-auto -mx-0.5" },
          md: { root: "px-4 py-2.5 text-sm gap-1.5", visual: "h-4.5 w-auto -mx-0.5" },
          lg: { root: "px-5 py-3 text-base gap-1.5", visual: "h-5 w-auto -mx-0.5" }
        }

        derive :indicator_size, from: :size, values: { sm: :sm, md: :lg, lg: :lg }

        # Set when no text or content block was given, to render a square button
        toggle :visual_only, per: :size, internal: true, values: {
          sm: "p-2 *:h-5 *:mx-0",
          md: "p-2.5 *:h-5 *:mx-0",
          lg: "p-3 *:h-6 *:mx-0"
        }

        # The side of the control the button sits on, which the group selects
        # from the slot. The button has no border on the side facing the
        # control.
        variant :side, default: :leading, allow_none: false, internal: true, values: {
          leading: "rounded-s-lg border border-e-0",
          trailing: "rounded-e-lg border border-s-0"
        }

        # @param text [String, nil] the text of the button. Takes precedence over block content.
        # @param side [Symbol] the side of the control, +:leading+ or +:trailing+. The group sets it.
        # @param size [Symbol] the size, +:sm+, +:md+ or +:lg+. The group sets it to its own.
        # @param options [Hash] arguments of Gustwave::Buttons::Base, e.g. +tag+, +type+, and the button's HTML attributes.
        def initialize(text = nil, side: DEFAULT, size: DEFAULT, **options)
          super(text, size:, **options)
          select_options(side:)
        end
      end
    end
  end
end
