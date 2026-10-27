# frozen_string_literal: true

module Gustwave
  # One tab of Gustwave::Tabs: the list item with its trigger, a button or a
  # link, and the +panel+ slot shown when a button tab is selected.
  #
  # Tabs builds its tabs through the +tabs+ slot, so set a tab's content with
  # +with_tab_button+ or +with_tab_link+ rather than rendering a Tab directly.
  # Inside the block, set the visuals and the panel:
  #
  #   <%= render Gustwave::Tabs.new do |tabs| %>
  #     <% tabs.with_tab_button("Profile") do |tab| %>
  #       <% tab.with_leading_visual_icon(:user_circle) %>
  #       <% tab.with_panel(class: "p-6") do %>Profile content<% end %>
  #     <% end %>
  #   <% end %>
  #
  # A link tab has no panel. Setting one raises when Gustwave is strict, and
  # is ignored otherwise.
  class Tab < Gustwave::Component
    include Gustwave::Visuals

    # Sizes the leading and trailing visuals to the tab's text
    variant :size, internal: true, default: :sm, values: { sm: { visual: "w-4 h-4" } }

    # The size of the leading and trailing indicators per tab size
    derive :indicator_size, from: :size, values: { none: :none, sm: :md }

    # The panel of a button tab, shown while the tab is selected. Its
    # options are HTML attributes of the panel element.
    #
    #   tab.with_panel(class: "p-6") do
    #     "Profile content"
    #   end
    renders_one_extensible :panel, ->(**options, &block) {
      @panel_options = options
      block ? capture(&block) : ""
    }

    # @param text [String, nil] the label of the tab. Takes precedence over block content.
    # @param id [String, nil] the id of the tab, which its panel is labelled by. Defaults to a random id. Button tabs only.
    # @param href [String, nil] the URL of a link tab.
    # @param link [Boolean] whether the tab is a link rather than a button. Set by Tabs.
    # @param selected [Boolean] whether the tab is selected when it's rendered. Tabs decides the selection of button tabs.
    # @param disabled [Boolean] whether the tab is disabled.
    # @param options [Hash] additional HTML attributes of the trigger element.
    def initialize(text = nil, id: nil, href: nil, link: false, selected: false, disabled: false, **options)
      @text = text
      @link = link == true
      @id = id || generate_random_id(prefix: "tab") unless @link
      @href = href
      @selected = selected == true
      @disabled = disabled == true
      @options = options
    end

    # @return [Boolean] whether the tab is selected. Before Tabs renders it, this is the +selected:+ it was given.
    def selected?
      @selected
    end

    def disabled?
      @disabled
    end

    def link?
      @link
    end

    # Hands over the selection of the tab. Tabs calls it before rendering.
    #
    # @param selected [Boolean] whether the tab is selected.
    # @param interactive [Boolean] whether the list is interactive, i.e. Flowbite's JS toggles its panels. Otherwise the tabs are navigation links.
    def configure_selection(selected:, interactive:)
      @selected = selected == true
      @interactive = interactive == true
    end

    # Hands over the classes of the tab. Tabs calls it before rendering.
    #
    # @param item [String, nil] the classes of the list item.
    # @param tab [String, nil] the classes of the trigger.
    # @param panel [String, nil] the classes of the panel.
    # @param states [Hash{Symbol => String, nil}] the classes of the +:active+, +:inactive+ and +:disabled+ states.
    # @param edge [String, nil] the classes of the first or last tab, if any.
    def configure_classes(item:, tab:, panel:, states:, edge: nil)
      @item_class = item
      @tab_class = tab
      @panel_class = panel
      @states = states
      @edge_class = edge
    end

    # The panel of a selected or unselected button tab, as an element that
    # Flowbite's JS toggles with the +hidden+ class. Disabled tabs and link
    # tabs have no panel.
    #
    # @return [String, nil] the panel element, or +nil+ if the tab has none.
    def panel_element
      return if link? || disabled? || !@interactive

      tag.div panel.to_s, **panel_attributes
    end

    def before_render
      # Evaluates the block first, so the visuals and the panel are set
      content
      if link? && panel? && Gustwave.strict?
        raise ArgumentError, "a link tab can't have a panel"
      end

      select_options(has_visual: has_visual?)
    end

    def call
      tag.li role: ("presentation" if @interactive), class: @item_class do
        trigger_element
      end
    end

    private

    attr_reader :text

    def trigger_element
      label = slots_and_content(leading_visuals, text_or_content(text), trailing_visuals, append_content: false)

      if link?
        tag.a label, **trigger_attributes
      else
        tag.button label, **trigger_attributes
      end
    end

    def trigger_attributes
      own = link? ? link_attributes : button_attributes
      { **@options.except(:class), **own, class: trigger_classes }
    end

    def button_attributes
      if disabled?
        { id: trigger_id, type: "button", disabled: true, "aria-disabled": "true" }
      else
        {
          id: trigger_id,
          type: "button",
          role: "tab",
          "data-tabs-target": "##{id}",
          "aria-controls": id,
          "aria-selected": selected?.to_s
        }
      end
    end

    def link_attributes
      attributes = {}
      attributes[:href] = @href unless disabled?
      attributes[:"aria-current"] = "page" if selected?
      attributes[:"aria-disabled"] = "true" if disabled?
      attributes
    end

    # The state classes are merged last, so they win conflicts with the tab's
    # own classes. A caller's class: that conflicts with them breaks the swap
    # Flowbite's JS does, see Gustwave::Tabs.
    def trigger_classes
      merge_classes(@tab_class, @edge_class, state_classes, @options[:class]).presence
    end

    def state_classes
      return @states[:disabled] if disabled?

      selected? ? @states[:active] : @states[:inactive]
    end

    def panel_attributes
      options = (@panel_options || {}).except(:class)
      panel_class = [
        ("hidden" unless selected?),
        merge_classes(@panel_class, @panel_options&.dig(:class))
      ].compact_blank.join(" ").presence

      { **options, id:, role: "tabpanel", "aria-labelledby": trigger_id, class: panel_class }
    end

    def trigger_id
      "#{id}-tab"
    end

    attr_reader :id
  end
end
