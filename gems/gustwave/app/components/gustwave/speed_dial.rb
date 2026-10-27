# frozen_string_literal: true

module Gustwave
  # Use SpeedDial to render a floating button that expands into a menu of
  # actions. Matches Flowbite's speed dial.
  #
  # The trigger comes first in the DOM, followed by the menu of actions, so
  # the tab order runs trigger, then actions. The +direction+ places the menu
  # relative to the trigger.
  #
  # The menu is shown and hidden by Flowbite's JavaScript, which needs the
  # Flowbite Dial behavior loaded. Its +data-dial-init+ wrapper and trigger
  # attributes come from this component.
  #
  # === Example
  #
  #   <%= render Gustwave::SpeedDial.new do |dial| %>
  #     <% dial.with_action("Edit", icon: :edit) %>
  #     <% dial.with_action("Share", icon: :link) %>
  #   <% end %>
  #
  # @param id [String, nil] the id of the menu element. If not provided, a random id will be generated.
  # @param position [Symbol] where the speed dial is placed. +:bottom_right+ (default), +:bottom_left+, +:top_right+, +:top_left+, or +:none+ to render in the flow of the page.
  # @param direction [Symbol, nil] the direction the menu opens in, +:up+, +:down+, +:left+ or +:right+. Defaults to +:up+ for bottom positions and +:down+ for top positions.
  # @param trigger_event [Symbol] how the menu opens, +:hover+ (default) or +:click+.
  # @param shape [Symbol] the shape of the trigger and actions, +:round+ (default) or +:square+.
  # @param label_display [Symbol] where the labels of the actions are shown, +:tooltip+ (default), +:inside+ or +:outside+.
  # @param options [Hash] HTML attributes for the wrapper element.
  class SpeedDial < Gustwave::Component
    # The id of the menu element shown when the trigger is activated
    attr_reader :menu_id

    base "group flex items-center gap-4"
    part :menu, "hidden not-[.hidden]:flex items-center gap-2" # never plain `flex`: class_merge drops it next to `hidden`

    # Where the speed dial is placed on the page, +:none+ renders it in the flow
    variant :position, default: :bottom_right, values: {
      none: "",
      bottom_right: "fixed end-6 bottom-6",
      bottom_left: "fixed start-6 bottom-6",
      top_right: "fixed end-6 top-6",
      top_left: "fixed start-6 top-6"
    }

    # Where the menu opens relative to the trigger
    variant :direction, default: :up, values: {
      up:    { root: "flex-col-reverse", menu: "flex-col" },
      down:  { root: "flex-col",         menu: "flex-col" },
      left:  { root: "flex-row-reverse", menu: "flex-row" },
      right: { root: "flex-row",         menu: "flex-row" }
    }

    # The direction per position, when no direction is given
    derive :default_direction, from: :position, values: {
      none: :up, bottom_right: :up, bottom_left: :up, top_right: :down, top_left: :down
    }

    # Side of the actions their tooltip or outside label goes, for up/down
    derive :label_side, from: :position, values: {
      none: :left, bottom_right: :left, top_right: :left, bottom_left: :right, top_left: :right
    }

    # Whether the menu opens on hover or on click
    option :trigger_event, default: :hover, values: %i[hover click]

    # The shape of the trigger and actions
    option :shape, default: :round, values: %i[round square]

    # Where the labels of the actions are shown
    option :label_display, default: :tooltip, values: %i[tooltip inside outside]

    # Renders the trigger button, which opens the menu. Pass +text+ for its
    # screen reader label, +icon+ to change the icon and block content to
    # replace the icon. Its options are forwarded to Gustwave::SpeedDials::Trigger.
    renders_one_extensible :trigger, ->(text = nil, icon: :plus, **options) {
      Gustwave::SpeedDials::Trigger.new(text, icon:, **dial_trigger_attributes(options))
    }

    # Renders an action of the menu. Its label is shown as set by +label_display+,
    # unless the action passes its own +label_display+.
    renders_many_extensible :actions, ->(text, icon: nil, **options) {
      Gustwave::SpeedDials::Action.new(
        text,
        icon:,
        **configure_html_attributes(options, shape: option_value(:shape), label_display: option_value(:label_display),
                                             label_placement:)
      )
    }

    # @param id [String, nil] the id of the menu element. If not provided, a random id will be generated.
    # @param position [Symbol] the position of the speed dial, see the class documentation.
    # @param direction [Symbol, nil] the direction the menu opens in. Defaults per position when +nil+.
    # @param trigger_event [Symbol] +:hover+ or +:click+.
    # @param shape [Symbol] +:round+ or +:square+.
    # @param label_display [Symbol] +:tooltip+, +:inside+ or +:outside+.
    # @param options [Hash] HTML attributes for the wrapper element.
    def initialize(id: nil,
                   position: DEFAULT,
                   direction: DEFAULT,
                   trigger_event: DEFAULT,
                   shape: DEFAULT,
                   label_display: DEFAULT,
                   **options)
      @menu_id = id.presence || generate_random_id(prefix: "speed-dial")

      select_options(position:)
      direction = derived_value(:default_direction) if direction.nil? || direction.equal?(DEFAULT)
      select_options(direction:, trigger_event:, shape:, label_display:)

      @options = attributes_for(options)
    end

    def before_render
      @config = configure_html_attributes(@options, data: { dial_init: true })
    end

    def call
      tag.div(**config) do
        safe_join([ trigger || default_trigger, tag.div(id: menu_id, class: classes(:menu)) { safe_join(actions) } ])
      end
    end

    private

    attr_reader :config

    # The trigger built by the +trigger+ slot's builder, when no trigger is set
    def default_trigger
      render build_slot_trigger
    end

    # The trigger's dial attributes. They win over the caller's +data+ and
    # +aria+ keys of the same name, and the caller's other keys are kept.
    def dial_trigger_attributes(options)
      attributes = configure_html_attributes(options, shape: option_value(:shape))
      attributes.merge(
        data: (attributes[:data] || {}).merge(dial_toggle: menu_id, dial_trigger: option_value(:trigger_event)),
        aria: (attributes[:aria] || {}).merge(controls: menu_id, expanded: "false")
      )
    end

    # The side of the tooltip or outside label of the actions. Menus that open
    # sideways put their labels above the actions.
    def label_placement
      return :top if %i[left right].include?(option_value(:direction))

      derived_value(:label_side)
    end
  end
end
