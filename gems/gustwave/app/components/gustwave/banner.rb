# frozen_string_literal: true

module Gustwave
  # A bar fixed to the top or bottom of the page, as in Flowbite's sticky
  # banners.
  #
  # Pass the message as +text+ or as a block. The body takes the width next to
  # the dismiss button and is a plain block, so text and links flow inline and
  # a heading and a paragraph stack. Compose anything else in the block, e.g. a
  # call to action or an inline form:
  #
  #   render Gustwave::Banner.new("We've updated our terms.")
  #   render Gustwave::Banner.new("We've updated our terms.", position: :bottom)
  #
  # Floating, as a centered card instead of a full-width bar. With a call to
  # action, this is Flowbite's marketing banner:
  #
  #   render Gustwave::Banner.new(floating: true, align: :start) do |banner|
  #     banner.with_dismiss_button
  #     tag.div(class: "flex flex-col gap-3 md:flex-row md:items-center md:justify-between") do
  #       safe_join([ tag.span("Get 20% off."), render(Gustwave::Buttons::Default.new("Sign up", tag: :a, href: "/signup", size: :xs)) ])
  #     end
  #   end
  #
  # Dismissible, see +dismiss_button+. The banner gets an +id+ the button
  # targets, unless you pass one:
  #
  #   render Gustwave::Banner.new("We've updated our terms.") do |banner|
  #     banner.with_dismiss_button
  #   end
  #
  # It has no default role, because +banner+ is the landmark of the site
  # header. If it needs a landmark, pass
  # +role: "region", aria: { label: "..." }+.
  class Banner < Gustwave::Component
    attr_reader :id

    base "z-50 flex items-center gap-4 p-4 bg-gray-50 border-gray-200 dark:bg-gray-700 dark:border-gray-600"

    variant :position, default: :top, values: {
      top: "fixed top-0 start-0 w-full border-b",
      bottom: "fixed bottom-0 start-0 w-full border-t"
    }

    variant :align, part: :body, default: :center, values: {
      center: "text-center",
      start: "text-start"
    }

    # A centered card instead of a full-width bar
    toggle :floating, per: :position, values: {
      top: "top-6 start-1/2 -translate-x-1/2 rtl:translate-x-1/2 w-[calc(100%-2rem)] lg:max-w-7xl bg-white border border-gray-100 rounded-lg shadow-xs",
      bottom: "bottom-6 start-1/2 -translate-x-1/2 rtl:translate-x-1/2 w-[calc(100%-2rem)] lg:max-w-7xl bg-white border border-gray-100 rounded-lg shadow-xs"
    }

    part :body, "flex-1 min-w-0 text-sm font-normal text-gray-500 dark:text-gray-400"
    # +p-0+ leaves the w-6 icon its full size: +p-1.5+ would squeeze it to 16px.
    # Stays at the top next to content that stacks on small screens.
    part :dismiss_button, "shrink-0 self-start md:self-center inline-flex items-center justify-center w-7 h-7 p-0 rounded-lg text-sm text-gray-400 hover:bg-gray-200 hover:text-gray-900 dark:hover:bg-gray-600 dark:hover:text-white"

    # Renders a dismiss button to dismiss the banner visually.
    #
    # @param text [String, nil] text to display to screen readers. If missing block content is rendered without +sr-only+ markup. If both are missing a localized version of "Dismiss" is used.
    # @param icon [Symbol] The icon to use for the dismiss button. Defaults to +:close+.
    # @param options [Hash] Additional HTML options passed to the button component.
    renders_one_extensible :dismiss_button, ->(text = nil, icon: :close, **options) {
      # Make sure the banner has an id that can be used to dismiss it.
      @id ||= generate_random_id(prefix: "banner")

      # Gustwave's icons draw within the middle half of their box, so this
      # matches Flowbite's w-3 h-3 close icon
      Gustwave::DismissButton.new(@id, text, icon:, icon_options: { class: "w-6 h-6" },
                                  **{ color: :none }.merge(attributes_for(:dismiss_button, options)))
    }

    # @param text [String, nil] Text to display within the banner. Takes precedence over block content.
    # @param position [Symbol] Where the banner is fixed, :top or :bottom. Defaults to :top.
    # @param floating [Boolean] Whether the banner is a centered card instead of a full-width bar. Defaults to +false+.
    # @param align [Symbol] How the body aligns, :center or :start. Defaults to :center.
    # @param options [Hash] Additional HTML options passed to the component.
    def initialize(text = nil, position: DEFAULT, floating: false, align: DEFAULT, **options)
      @text = text
      @id = options.delete(:id)
      @options = { tabindex: -1 }.merge(options)

      select_options(position:, floating:, align:)
    end

    def before_render
      # Must evaluate here, so a dismiss button can generate the id first
      dismiss_button?
      @config = attributes_for(@options)
      @config[:id] = id
    end

    def call
      content_tag :div, config do
        slots_and_content(
          tag.div(text_or_content(text), class: classes(:body)),
          dismiss_button,
          append_content: false
        )
      end
    end

    private
    attr_reader :config, :text
  end
end
