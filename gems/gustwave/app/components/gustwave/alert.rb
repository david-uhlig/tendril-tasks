# frozen_string_literal: true

module Gustwave
  # A message that stands out from the page, as in Flowbite's alerts.
  #
  # Pass the message as +text+ or as a block. The +title+ renders in bold
  # before it. Spacing around the alert is up to the caller, e.g.
  # +class: "mb-4"+.
  #
  #   render Gustwave::Alert.new("A simple info alert.")
  #   render Gustwave::Alert.new("Check the form.", color: :red, border: true)
  #
  # With an icon, e.g. to illustrate the color. The +label+ is read by screen
  # readers:
  #
  #   render Gustwave::Alert.new("A simple info alert.") do |alert|
  #     alert.icon(label: "Info")
  #   end
  #
  # With a title and a list, top-aligning the icon:
  #
  #   render Gustwave::Alert.new(title: "Ensure that these requirements are met:", align: :start) do |alert|
  #     alert.icon(label: "Info")
  #     tag.ul("...", class: "mt-1.5 list-disc list-inside")
  #   end
  #
  # Dismissible, see +dismiss_button+. The alert gets an +id+ the button
  # targets, unless you pass one:
  #
  #   render Gustwave::Alert.new("A simple info alert.", color: :green) do |alert|
  #     alert.icon(label: "Info")
  #     alert.dismiss_button
  #   end
  #
  # Use +border+ for a border all around and +accent+ for a thick border at
  # the top only.
  class Alert < Gustwave::Component
    attr_reader :id

    base "p-4 text-sm rounded-lg"
    unstyled color: :none

    # The +dismiss_button+ part colors the dismiss button to match.
    variant :color, default: :blue, values: {
      blue: {
        root: "text-blue-800 bg-blue-50 dark:bg-gray-800 dark:text-blue-400",
        dismiss_button: "bg-blue-50 text-blue-500 hover:bg-blue-200 focus:ring-blue-400 dark:bg-gray-800 dark:text-blue-400 dark:hover:bg-gray-700"
      },
      red: {
        root: "text-red-800 bg-red-50 dark:bg-gray-800 dark:text-red-400",
        dismiss_button: "bg-red-50 text-red-500 hover:bg-red-200 focus:ring-red-400 dark:bg-gray-800 dark:text-red-400 dark:hover:bg-gray-700"
      },
      green: {
        root: "text-green-800 bg-green-50 dark:bg-gray-800 dark:text-green-400",
        dismiss_button: "bg-green-50 text-green-500 hover:bg-green-200 focus:ring-green-400 dark:bg-gray-800 dark:text-green-400 dark:hover:bg-gray-700"
      },
      yellow: {
        root: "text-yellow-800 bg-yellow-50 dark:bg-gray-800 dark:text-yellow-300",
        dismiss_button: "bg-yellow-50 text-yellow-500 hover:bg-yellow-200 focus:ring-yellow-400 dark:bg-gray-800 dark:text-yellow-300 dark:hover:bg-gray-700"
      },
      dark: {
        root: "text-gray-800 bg-gray-50 dark:bg-gray-800 dark:text-gray-300",
        dismiss_button: "bg-gray-50 text-gray-500 hover:bg-gray-200 focus:ring-gray-400 dark:bg-gray-800 dark:text-gray-300 dark:hover:bg-gray-700 dark:hover:text-white"
      }
    }

    # Top-aligns the icon, e.g. for alerts with a title and a list. Only
    # flex alerts align, see +flex+.
    variant :align, default: :center, values: {
      center: "",
      start: { root: "", icon: "mt-[2px]" }
    }

    toggle :border, per: :color, values: {
      blue: "border border-blue-300 dark:border-blue-800",
      red: "border border-red-300 dark:border-red-800",
      green: "border border-green-300 dark:border-green-800",
      yellow: "border border-yellow-300 dark:border-yellow-800",
      dark: "border border-gray-300 dark:border-gray-600"
    }

    # Wins over +border+ if both are set: +border-0+ drops its width.
    toggle :accent, per: :color, values: {
      blue: "border-0 border-t-4 border-blue-300 rounded-none dark:border-blue-800",
      red: "border-0 border-t-4 border-red-300 rounded-none dark:border-red-800",
      green: "border-0 border-t-4 border-green-300 rounded-none dark:border-green-800",
      yellow: "border-0 border-t-4 border-yellow-300 rounded-none dark:border-yellow-800",
      dark: "border-0 border-t-4 border-gray-300 rounded-none dark:border-gray-600"
    }

    # Set when the alert renders an icon or a dismiss button
    toggle :flex, per: :align, internal: true, values: {
      center: "flex items-center",
      start: "flex"
    }

    # Set when the alert renders a dismiss button, as in Flowbite's
    # dismissible alerts
    toggle :dismissible, "font-medium", part: :body, internal: true

    part :icon, "shrink-0 inline w-4 h-4 me-3"
    part :body
    part :title, "font-medium"
    # +ms-auto+ follows +-mx-1.5+, or the class merger drops it
    part :dismiss_button, "-mx-1.5 -my-1.5 ms-auto p-1.5 h-8 w-8 rounded-lg focus:ring-2 inline-flex items-center justify-center"

    # Renders an icon before the alert's text.
    #
    # @param name [Symbol] The icon to use. Defaults to +:info_circle+.
    # @param label [String, nil] Text to display to screen readers, e.g. "Info".
    # @param theme [Symbol] The icon theme. Defaults to +:solid+.
    # @param options [Hash] Additional HTML options passed to the icon component.
    renders_one_extensible :icon_slot, ->(name = :info_circle, label: nil, theme: :solid, **options) {
      icon = Gustwave::Icon.new(name, theme:, size: :sm, position: :standalone, **attributes_for(:icon, options))
      safe_join([ render(icon), sr_only(label) ].compact)
    }
    alias icon with_icon_slot

    # Renders a dismiss button to dismiss the alert visually.
    #
    # @param text [String, nil] text to display to screen readers. If missing block content is rendered without +sr-only+ markup. If both are missing a localized version of "Dismiss" is used.
    # @param icon [Symbol] The icon to use for the dismiss button. Defaults to +:close+.
    # @param options [Hash] Additional HTML options passed to the button component.
    renders_one_extensible :dismiss_button_slot, ->(text = nil, icon: :close, **options, &block) {
      # Make sure the alert has an id that can be used to dismiss it.
      @id ||= generate_random_id(prefix: "alert")

      a11y_text = sr_only(text) || (capture(&block) if block.present?) || sr_only(t(".dismiss"))
      config = {
        theme: :inline,
        color: :none,
        aria: { label: text.presence || t(".dismiss") },
        data: { dismiss_target: "##{@id}" }
      }.merge(attributes_for(:dismiss_button, options))

      component = Gustwave::Button.new(a11y_text, **config)
      # Gustwave's icons draw within the middle half of their box, so this
      # matches Flowbite's w-3 h-3 close icon
      component.leading_icon icon, stroke_width: 2, class: "w-6 h-6" if icon
      component
    }
    alias dismiss_button with_dismiss_button_slot

    # @param text [String, nil] Text to display within the alert. Takes precedence over block content.
    # @param title [String, nil] A title rendered in bold before the text.
    # @param color [Symbol] The color of the alert. Defaults to :blue.
    # @param align [Symbol] How the icon aligns with the text, :center or :start. Defaults to :center.
    # @param border [Boolean] Whether the alert has a border. Defaults to +false+.
    # @param accent [Boolean] Whether the alert has a thick border at the top only. Wins over +border+. Defaults to +false+.
    # @param options [Hash] Additional HTML options passed to the component.
    def initialize(text = nil, title: nil, color: DEFAULT, align: DEFAULT, border: false, accent: false, **options)
      @text = text
      @title = title
      @id = options.delete(:id)
      @options = { role: "alert" }.merge(options)

      select_options(color:, align:, border:, accent:)
    end

    def before_render
      # Must select here to know whether slots were set
      select_options(flex: icon_slot? || dismiss_button_slot?, dismissible: dismiss_button_slot?)
      @config = attributes_for(@options)
      @config[:id] = id
    end

    def call
      content_tag :div, config do
        if icon_slot? || dismiss_button_slot?
          slots_and_content(
            icon_slot,
            tag.div(body, class: classes(:body)),
            dismiss_button_slot,
            append_content: false
          )
        else
          body
        end
      end
    end

    private
    attr_reader :config, :text

    def body
      safe_join([ title_tag, text_or_content(text) ].compact, " ")
    end

    def title_tag
      tag.span(@title, class: classes(:title)) if @title.present?
    end
  end
end
