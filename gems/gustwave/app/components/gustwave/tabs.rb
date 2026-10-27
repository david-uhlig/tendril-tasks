# frozen_string_literal: true

module Gustwave
  # Use Tabs to render a set of tabs, as in Flowbite's tabs.
  #
  # Two kinds of tabs, which can't be mixed in strict mode:
  #
  # * Button tabs, with panels. Flowbite's JS shows the panel of the selected
  #   tab and hides the others. The selected tab is the first one given
  #   +selected: true+ that isn't disabled, or else the first one that isn't
  #   disabled.
  # * Link tabs, for navigation. Each link is a page, so nothing is selected
  #   unless given +selected: true+, and the selected one is marked
  #   +aria-current="page"+.
  #
  #   <%= render Gustwave::Tabs.new(style: :underline) do |tabs| %>
  #     <% tabs.with_tab_button("Profile") do |tab| %>
  #       <% tab.with_panel do %>Profile content<% end %>
  #     <% end %>
  #     <% tabs.with_tab_button("Settings", selected: true) do |tab| %>
  #       <% tab.with_panel(class: "p-6") do %>Settings content<% end %>
  #     <% end %>
  #     <% tabs.with_tab_button("Disabled", disabled: true) %>
  #   <% end %>
  #
  #   <%= render Gustwave::Tabs.new(style: :pills, aria: { label: "Account" }) do |tabs| %>
  #     <% tabs.with_tab_link("Profile", href: profile_path, selected: true) %>
  #     <% tabs.with_tab_link("Billing", href: billing_path) %>
  #   <% end %>
  #
  # The +style+ and +vertical+ options set the classes of every part, see
  # Gustwave::Tab for the parts of a tab. A tab's own classes come from the
  # +tabs+ slot's +with_tab_button+ and +with_tab_link+ setters.
  #
  # === Active and inactive classes
  #
  # Flowbite's JS swaps the +active+ and +inactive+ classes of a tab when it's
  # selected. The +active_class+ and +inactive_class+ options replace the
  # classes of these states, e.g. for purple tabs. The classes of the active
  # and inactive states must not share a class, and a trigger's own +class:+
  # must not conflict with its state's classes, or the swap breaks.
  class Tabs < Gustwave::Component
    # Parts shared by every style
    part :list, "flex flex-wrap text-sm font-medium text-center"
    part :panel, "p-4 rounded-lg bg-gray-50 dark:bg-gray-800"
    part :nav
    part :item
    part :tab
    part :active
    part :inactive
    part :disabled
    part :first_tab
    part :last_tab
    part :panels

    # Classes of the tabs' parts for each +style+. +:none+ renders no classes.
    variant :style, default: :default, values: {
      default: {
        list: "text-gray-500 border-b border-gray-200 dark:border-gray-700 dark:text-gray-400",
        item: "me-2",
        tab: "inline-block p-4 rounded-t-lg",
        active: "text-blue-600 bg-gray-100 dark:bg-gray-800 dark:text-blue-500",
        inactive: "hover:text-gray-600 hover:bg-gray-50 dark:hover:bg-gray-800 dark:hover:text-gray-300",
        disabled: "text-gray-400 cursor-not-allowed dark:text-gray-500"
      },
      underline: {
        nav: "mb-4 border-b border-gray-200 dark:border-gray-700",
        list: "-mb-px text-gray-500 dark:text-gray-400",
        item: "me-2",
        tab: "inline-block p-4 border-b-2 rounded-t-lg",
        active: "text-blue-600 hover:text-blue-600 dark:text-blue-500 dark:hover:text-blue-500 border-blue-600 dark:border-blue-500",
        inactive: "dark:border-transparent text-gray-500 hover:text-gray-600 dark:text-gray-400 border-gray-100 hover:border-gray-300 dark:border-gray-700 dark:hover:text-gray-300",
        disabled: "text-gray-400 border-transparent cursor-not-allowed dark:text-gray-500"
      },
      pills: {
        list: "text-gray-500 dark:text-gray-400",
        item: "me-2",
        tab: "inline-block px-4 py-3 rounded-lg",
        active: "text-white bg-blue-600",
        inactive: "hover:text-gray-900 hover:bg-gray-100 dark:hover:bg-gray-800 dark:hover:text-white",
        disabled: "text-gray-400 cursor-not-allowed dark:text-gray-500"
      },
      full_width: {
        list: "flex-nowrap text-gray-500 rounded-lg shadow-sm dark:divide-gray-700 dark:text-gray-400",
        item: "w-full focus-within:z-10",
        tab: "inline-block w-full p-4 border-r border-gray-200 dark:border-gray-700 focus:ring-4 focus:ring-blue-300 focus:outline-none",
        first_tab: "rounded-s-lg",
        last_tab: "rounded-e-lg border-r-0",
        active: "text-gray-900 bg-gray-100 dark:bg-gray-700 dark:text-white",
        inactive: "bg-white hover:text-gray-700 hover:bg-gray-50 dark:hover:text-white dark:bg-gray-800 dark:hover:bg-gray-700",
        disabled: "text-gray-400 bg-white cursor-not-allowed dark:bg-gray-800 dark:text-gray-500"
      }
    }

    unstyled style: :none

    # Classes shared by the vertical layout of every style
    VERTICAL = {
      root: "md:flex",
      list: "flex-col flex-nowrap space-y-4 md:me-4 mb-4 md:mb-0",
      item: "me-0",
      tab: "w-full",
      panels: "w-full",
      panel: "p-6"
    }.freeze

    # The vertical layout per +style+, with the classes of each style
    toggle :vertical, per: :style, values: {
      none: "",
      default: VERTICAL.merge(
        list: "#{VERTICAL[:list]} border-b-0 border-e",
        tab: "#{VERTICAL[:tab]} rounded-t-none rounded-s-lg"
      ),
      underline: VERTICAL.merge(
        nav: "mb-0 border-b-0 border-e",
        list: "#{VERTICAL[:list]} -mb-0 -me-px",
        tab: "#{VERTICAL[:tab]} border-b-0 border-e-2 rounded-t-none rounded-s-lg"
      ),
      pills: VERTICAL.merge(
        tab: "#{VERTICAL[:tab]} inline-flex items-center",
        active: "bg-blue-700 dark:bg-blue-600",
        inactive: "bg-gray-50 dark:bg-gray-800 dark:hover:bg-gray-700",
        disabled: "bg-gray-50 dark:bg-gray-800"
      ),
      full_width: VERTICAL.merge(
        tab: "#{VERTICAL[:tab]} border-r-0 border-b",
        first_tab: "rounded-t-lg",
        last_tab: "rounded-b-lg border-b-0"
      )
    }

    renders_many_extensible :tabs, types: {
      button: ->(text = nil, id: nil, selected: false, disabled: false, **options) {
        Gustwave::Tab.new(text, id:, selected:, disabled:, **options)
      },
      link: ->(text = nil, href: nil, selected: false, disabled: false, **options) {
        Gustwave::Tab.new(text, href:, link: true, selected:, disabled:, **options)
      }
    }

    # @param id [String, nil] the id of the root element. Defaults to a random id.
    # @param style [Symbol] the style of the tabs: +:default+, +:underline+, +:pills+ or +:full_width+.
    # @param vertical [Boolean] whether the tabs are stacked in a column, beside their panels.
    # @param active_class [String, nil] classes of the selected tab that replace the style's, e.g. +"text-purple-600 border-purple-600"+. They win conflicts with the style's classes.
    # @param inactive_class [String, nil] classes of the unselected tabs that replace the style's. They win conflicts with the style's classes.
    # @param options [Hash] additional HTML attributes of the root element. For link tabs, which render in a +nav+ element, this is that element, so pass +aria: { label: }+ here.
    def initialize(id: nil, style: DEFAULT, vertical: false, active_class: nil, inactive_class: nil, **options)
      @id = id || generate_random_id(prefix: "tabs")
      @active_class = active_class
      @inactive_class = inactive_class

      select_options(style:, vertical:)
      @options = attributes_for(options.merge(id: @id))
    end

    def before_render
      # Evaluates the block first, so the tabs are set
      content

      if Gustwave.strict? && tabs.any?(&:link?) && tabs.any? { !it.link? }
        raise ArgumentError, "Gustwave::Tabs can't mix button and link tabs"
      end

      @interactive = tabs.any? { !it.link? }
      @active_classes = classes(:active, class: @active_class).presence
      @inactive_classes = classes(:inactive, class: @inactive_class).presence
      configure_tabs
    end

    def call
      if @interactive
        interactive_tabs
      else
        navigation_tabs
      end
    end

    private

    attr_reader :id

    def configure_tabs
      enabled = tabs.each_index.select { |index| !tabs[index].link? && !tabs[index].disabled? }
      chosen = enabled.find { tabs[it].selected? } || enabled.first
      states = { active: @active_classes, inactive: @inactive_classes, disabled: classes(:disabled) }

      tabs.each_with_index do |tab, index|
        selected = @interactive ? index == chosen : tab.selected?
        tab.configure_selection(selected:, interactive: @interactive)
        tab.configure_classes(item: classes(:item), tab: classes(:tab), panel: classes(:panel), states:,
                              edge: edge_classes(index))
      end
    end

    def edge_classes(index)
      edges = []
      edges << classes(:first_tab) if index.zero?
      edges << classes(:last_tab) if index == tabs.size - 1
      merge_classes(edges)
    end

    def interactive_tabs
      tag.div **@options do
        safe_join([
          tag.div(**attributes_for(:nav)) { tablist },
          tag.div(id: panels_id, **attributes_for(:panels)) { safe_join(panel_elements) }
        ])
      end
    end

    def navigation_tabs
      tag.nav **attributes_for(:nav, @options) do
        tag.ul(class: classes(:list)) { safe_join(tab_items) }
      end
    end

    def tablist
      tag.ul id: list_id, role: "tablist", class: classes(:list),
             "data-tabs-toggle": "##{panels_id}",
             "data-tabs-active-classes": @active_classes,
             "data-tabs-inactive-classes": @inactive_classes do
        safe_join(tab_items)
      end
    end

    # Renders the tabs first: each tab evaluates its block, which sets its panel.
    def tab_items
      tabs.map(&:to_s)
    end

    def panel_elements
      tabs.filter_map(&:panel_element)
    end

    def list_id
      "#{id}-list"
    end

    def panels_id
      "#{id}-content"
    end
  end
end
