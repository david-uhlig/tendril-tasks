# frozen_string_literal: true

module Gustwave
  # A notification that floats on the page, as in Flowbite's toasts.
  #
  # A +status+ shows the status's icon in a colored box beside the text, and
  # names the status for screen readers. Replace the icon with +icon:+, or
  # with +with_visual_icon+ and the other visual types of Gustwave::Visuals:
  #
  #   render Gustwave::Toast.new("Saved.", status: :success)
  #   render Gustwave::Toast.new("New message.", status: :info, icon: :bell)
  #   render Gustwave::Toast.new("Uploaded.") { |toast| toast.with_visual_image("avatar.png", alt: "") }
  #
  # Toasts are dismissible by default: a close button in the corner removes
  # the toast. Customize it with +with_dismiss_button+:
  #
  #   render Gustwave::Toast.new("Saved.") do |toast|
  #     toast.with_dismiss_button(text: "Close notification")
  #   end
  #
  # With +dismissible: false+ no button is rendered, whatever the slot
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
    include Gustwave::Visuals
    renders_visuals :visuals
    self.visual_icon_theme = :solid

    base "flex items-center w-full max-w-xs p-4 text-gray-500 bg-white rounded-lg shadow-sm dark:text-gray-400 dark:bg-gray-800"

    # The box that holds the visuals beside the text
    part :visual_box, "inline-flex items-center justify-center shrink-0 w-8 h-8 rounded-lg"
    # The text beside the visuals
    part :message, "ms-3 text-sm font-normal"

    # Colors the visual box and picks its default icon. +:notice+, +:failure+
    # and +:alert+ are aliases for Rails' flash types.
    variant :status, part: :visual_box, default: :none, values: {
      info: "text-blue-500 bg-blue-100 dark:bg-blue-800 dark:text-blue-200",
      notice: "text-blue-500 bg-blue-100 dark:bg-blue-800 dark:text-blue-200",
      success: "text-green-500 bg-green-100 dark:bg-green-800 dark:text-green-200",
      error: "text-red-500 bg-red-100 dark:bg-red-800 dark:text-red-200",
      failure: "text-red-500 bg-red-100 dark:bg-red-800 dark:text-red-200",
      warning: "text-orange-500 bg-orange-100 dark:bg-orange-700 dark:text-orange-200",
      alert: "text-orange-500 bg-orange-100 dark:bg-orange-700 dark:text-orange-200"
    }

    # The icon per status
    derive :status_icon, from: :status, values: {
      info: :info_circle,
      notice: :info_circle,
      success: :check_circle,
      error: :close_circle,
      failure: :close_circle,
      warning: :exclamation_circle,
      alert: :exclamation_circle
    }

    # A standalone close button in the toast's corner. ms-auto comes after -mx-1.5
    # because tailwind_merge drops an earlier ms-* when a later mx-* follows.
    part :dismiss_button, "-mx-1.5 ms-auto shrink-0 -my-1.5 bg-white text-gray-400 hover:text-gray-900 rounded-lg focus:ring-2 focus:ring-gray-300 p-1.5 hover:bg-gray-100 inline-flex items-center justify-center dark:text-gray-500 dark:hover:text-white dark:bg-gray-800 dark:hover:bg-gray-700 h-8 w-8 [&>svg]:w-6 [&>svg]:h-6 [&>svg]:mx-0"

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

    # @param text [String, nil] The text of the toast. Takes precedence over block content.
    # @param status [Symbol] +:info+, +:success+, +:error+ or +:warning+, or the flash aliases +:notice+, +:failure+ and +:alert+. Shows the status's icon. Defaults to +:none+, no icon.
    # @param icon [Symbol, nil] Shorthand for +with_visual_icon+: replaces the status's icon. Solid by default.
    # @param position [Symbol] Fixes the toast to a corner or edge of the page. Defaults to +:none+.
    # @param id [String, nil] The id of the toast, which its dismiss button targets. Generated if missing.
    # @param dismissible [Boolean] Whether the toast has a dismiss button. Defaults to +true+.
    # @param auto_remove [Boolean] Animates and removes the toast after a few
    #   seconds, pausing while hovered. Needs the Stimulus controller
    #   +gustwave--animate-and-remove+ that Gustwave ships. Off by default.
    # @param options [Hash] HTML attributes for the toast element.
    def initialize(text = nil,
                   status: DEFAULT,
                   icon: nil,
                   position: DEFAULT,
                   id: nil,
                   dismissible: true,
                   auto_remove: false,
                   **options)
      @text = text
      @icon = icon
      @id = id.presence || generate_random_id(prefix: "toast")
      @dismissible = ActiveModel::Type::Boolean.new.cast(dismissible) != false

      select_options(status:, position:)
      options = options.deep_symbolize_keys
      options = merge_data_tokens(options, controller: CONTROLLER, action: AUTO_REMOVE_ACTIONS) if ActiveModel::Type::Boolean.new.cast(auto_remove)
      @options = attributes_for({ id: @id, role: "alert" }.merge(options))
    end

    def dismissible?
      @dismissible
    end

    def before_render
      icon = @icon || derived_value(:status_icon)
      with_visual_icon(icon) if icon && !visuals?
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

      Gustwave::DismissButton.new(@id, text, icon:,
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

    # Names the status for screen readers, as the icon is hidden from them
    def status_label
      status = option_value(:status)
      t(".#{status}") unless status == :none
    end
  end
end
