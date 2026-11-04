# frozen_string_literal: true

module Gustwave
  # Use Navbar to render a responsive navigation bar, as in Flowbite's navbars:
  # a brand, a row of actions, and a menu of items that collapses behind a
  # hamburger toggle on small screens.
  #
  # Slot structure (all optional)
  # - +brand+ (any HTML markup, as a link when +href+ is given)
  # - +actions+ (any HTML markup), e.g. a call to action or a user menu
  # - +items+, the menu's list items:
  #   - +link+ (Gustwave::Navbars::Link), set with +with_item_link+
  #   - +generic+ (any HTML markup), set with +with_item_generic+
  #
  # The actions and the hamburger toggle share a row. The toggle only renders
  # when the navbar has items, and it controls the menu, whose id is
  # +menu_id+.
  #
  # Pass +sticky: true+ to keep the navbar at the top of the viewport. It is
  # then fixed and overlays the page, so the page content needs its own top
  # offset.
  #
  # Pass +solid: true+ for a grey background, as in Flowbite's "Solid
  # background" navbar.
  #
  # Items that aren't links, e.g. a dropdown or a search field, go in a
  # +generic+ item. Use +class: "md:hidden"+ on it to show it on small screens
  # only.
  #
  # Use +configure_container+ and +configure_menu+ to set the HTML attributes
  # of the container and the menu. Their classes win conflicts with the
  # defaults.
  #
  #   render Gustwave::Navbar.new do |navbar|
  #     navbar.with_brand(href: "/") do
  #       safe_join([
  #         render(Gustwave::Icon.new(:rocket, theme: :solid, position: :standalone, class: "size-8 text-blue-700 dark:text-blue-500")),
  #         tag.span("Flowbite", class: "self-center text-2xl font-semibold whitespace-nowrap dark:text-white")
  #       ])
  #     end
  #     navbar.with_item_link("Home", href: "/", active: true)
  #     navbar.with_item_link("About", href: "/about")
  #   end
  #
  # A composed dropdown, using a generic item:
  #
  #   render Gustwave::Navbar.new do |navbar|
  #     navbar.with_brand(href: "/") { "Flowbite" }
  #     navbar.with_item_generic do
  #       render Gustwave::Dropdown.new(...) # trigger and menu, see Gustwave::Dropdown
  #     end
  #   end
  class Navbar < Gustwave::Component
    base "bg-white border-gray-200 dark:bg-gray-900"

    part :container, "max-w-screen-xl flex flex-wrap items-center justify-between mx-auto p-4"
    part :brand, "flex items-center space-x-3 rtl:space-x-reverse"
    part :actions, "flex md:order-2 space-x-3 md:space-x-0 rtl:space-x-reverse"
    part :menu, "items-center justify-between hidden w-full md:flex md:w-auto md:order-1"
    part :list, "flex flex-col font-medium p-4 md:p-0 mt-4 border border-gray-100 rounded-lg bg-gray-50 md:flex-row md:gap-8 md:mt-0 md:border-0 md:bg-white dark:bg-gray-800 md:dark:bg-gray-900 dark:border-gray-700"
    part :toggle, "size-10 p-0 rounded-lg md:hidden text-gray-500 hover:bg-gray-100 hover:text-gray-500 focus:ring-gray-200 dark:text-gray-400 dark:hover:bg-gray-700 dark:hover:text-gray-400 dark:focus:ring-gray-600"

    toggle :sticky, "fixed w-full z-20 top-0 start-0 border-b border-gray-200 dark:border-gray-600"

    toggle :solid, {
      root: "bg-gray-50 dark:bg-gray-800 dark:border-gray-700",
      list: "p-0 border-0 md:bg-transparent md:dark:bg-transparent"
    }

    renders_one_extensible :brand, ->(href: nil, **options, &block) do
      brand = capture(&block)
      attributes = attributes_for(:brand, options)
      href ? render(Gustwave::Link.new(brand, href:, color: :none, underline: :none, **attributes)) : tag.div(brand, **attributes)
    end

    renders_one_extensible :actions, ->(&block) { capture(&block) }

    renders_many_extensible :items, types: {
      link: ->(text = nil, href:, active: false, **options, &block) do
        link = Gustwave::Navbars::Link.new(text, href:, active:, **options)
        link.with_content(capture(&block)) if block
        tag.li { render(link) }
      end,
      generic: ->(**options, &block) do
        tag.li(**options) { capture(&block) if block }
      end
    }

    attr_reader :menu_id

    # @param menu_id [String, nil] the id of the menu, which the toggle controls. Generated if +nil+.
    # @param sticky [Boolean] whether the navbar sticks to the top of the viewport. Defaults to +false+.
    # @param solid [Boolean] whether the navbar has a solid grey background. Defaults to +false+.
    # @param options [Hash] additional HTML attributes passed to the +nav+ element.
    def initialize(menu_id: nil, sticky: false, solid: false, **options)
      @menu_id = menu_id || generate_random_id(prefix: "navbar")
      select_options(sticky:, solid:)
      @config = attributes_for(options)
      configure_container
      configure_menu
      @list_config = attributes_for(:list, {})
    end

    # Configure the container element, which holds the brand, actions and menu.
    #
    # @param options [Hash] additional HTML attributes passed to the container element.
    def configure_container(**options)
      @container_config = attributes_for(:container, options)
    end

    # Configure the menu element, which holds the list of items.
    #
    # @param options [Hash] additional HTML attributes passed to the menu element. Its +id+ is always +menu_id+.
    def configure_menu(**options)
      @menu_config = attributes_for(:menu, options).merge(id: menu_id)
    end

    def before_render
      # With only the toggle inside, the empty container would keep the menu from the end of the row on wide screens.
      @actions_config = attributes_for(:actions, actions? ? {} : { class: "md:hidden" })
      @toggle = Gustwave::Buttons::Inline.new(sr_only(t(".open_main_menu")), color: :dark, **attributes_for(:toggle, {
        data: { collapse_toggle: menu_id },
        aria: { controls: menu_id, expanded: false }
      }))
      @toggle.with_leading_visual_icon(:bars, stroke_width: 2, class: "h-7 w-7")
    end

    private
    attr_reader :config, :container_config, :actions_config, :menu_config, :list_config,
                :toggle
  end
end
