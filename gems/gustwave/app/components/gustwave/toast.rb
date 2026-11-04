# frozen_string_literal: true

module Gustwave
  # A notification that floats on the page, as in Flowbite's toasts.
  #
  # Toasts are dismissible by default: a close button in the corner removes
  # the toast. Customize it with +with_dismiss_button+:
  #
  #   render Gustwave::Toast.new("Saved.") do |toast|
  #     toast.with_dismiss_button(text: "Close notification")
  #   end
  #
  # Without +dismissible: false+ no button is rendered, whatever the slot
  # holds.
  #
  # To place the button in your own layout, call +dismiss_button+ in the
  # block. The toast then doesn't render its own at the end. Set the button
  # before the call, as it customizes the button from then on:
  #
  #   <%= render Gustwave::Toast.new do |toast| %>
  #     <% toast.with_dismiss_button(text: "Close notification") %>
  #     <div class="flex"><%= toast.dismiss_button %></div>
  #   <% end %>
  #
  # @status alpha
  class Toast < Gustwave::Component
    base "flex items-center w-full max-w-xs p-4 text-gray-500 bg-white rounded-lg shadow-sm dark:text-gray-400 dark:bg-gray-800"

    # A standalone close button in the toast's corner. ms-auto comes after -mx-1.5
    # because tailwind_merge drops an earlier ms-* when a later mx-* follows.
    part :dismiss_button, "-mx-1.5 ms-auto shrink-0 -my-1.5 bg-white text-gray-400 hover:text-gray-900 rounded-lg focus:ring-2 focus:ring-gray-300 p-1.5 hover:bg-gray-100 inline-flex items-center justify-center dark:text-gray-500 dark:hover:text-white dark:bg-gray-800 dark:hover:bg-gray-700 h-8 w-8"

    variant :position, default: :none, values: {
      top_left: "fixed top-5 left-5",
      top_center: "fixed top-5 left-1/2 transform -translate-x-1/2",
      top_right: "fixed top-5 right-5",
      bottom_left: "fixed bottom-5 left-5",
      bottom_center: "fixed bottom-5 left-1/2 transform -translate-x-1/2",
      bottom_right: "fixed bottom-5 right-5"
    }

    CONTROLLER = "gustwave--animate-and-remove"
    AUTO_REMOVE_ACTIONS = %W[
      mouseover->#{CONTROLLER}#pause
      mouseout->#{CONTROLLER}#continue
    ].freeze

    # @param auto_remove [Boolean] Animates and removes the toast after a few
    #   seconds, pausing while hovered. Needs the Stimulus controller
    #   +gustwave--animate-and-remove+ that Gustwave ships. Off by default.
    def initialize(text = nil,
                   position: DEFAULT,
                   id: nil,
                   dismissible: true,
                   auto_remove: false,
                   **options)
      @text = text
      @id = id.presence || generate_random_id(prefix: "toast")
      @dismissible = ActiveModel::Type::Boolean.new.cast(dismissible) != false

      select_options(position:)
      options = options.deep_symbolize_keys
      options = merge_data_tokens(options, controller: CONTROLLER, action: AUTO_REMOVE_ACTIONS) if ActiveModel::Type::Boolean.new.cast(auto_remove)
      @options = attributes_for({ id: @id, role: "alert" }.merge(options))
    end

    def dismissible?
      @dismissible
    end

    # Renders a button that dismisses the toast, unless the toast isn't
    # dismissible. Customize it with +with_dismiss_button+, see the class docs.
    #
    # @param text [String, nil] text to display to screen readers. If missing block content is rendered without +sr-only+ markup. If both are missing a localized version of "Dismiss" is used.
    # @param icon [Symbol] The icon to use for the dismiss button. Defaults to +:close+.
    # @param options [Hash] Additional HTML options passed to the button component.
    renders_one_extensible :dismiss_button, ->(text = nil, icon: :close, **options) {
      # Accepts +text:+ too, as a keyword, since the lambda's positional
      # argument can't take it.
      text ||= options.delete(:text)

      Gustwave::DismissButton.new(@id, text, icon:, icon_options: { class: "h-6 w-6 mx-0" },
                                  **{ theme: :default, color: :none }.merge(attributes_for(:dismiss_button, options)))
    }

    # The button rendered when no +dismiss_button+ is set. Public, because
    # ViewComponent only finds +default_<slot>+ methods that are public.
    def default_dismiss_button
      build_slot_dismiss_button if dismissible?
    end

    # Marks the button as placed by a block, so the template doesn't render a
    # second one at the end. Renders nothing when the toast isn't dismissible.
    def dismiss_button
      @dismiss_button_rendered = true
      super if dismissible?
    end

    private

    attr_reader :text
  end
end
