# frozen_string_literal: true

module Gustwave
  # Use Dropdown to render a trigger that shows a menu when clicking it and
  # hides it when clicking outside
  #
  # By default, renders a trigger button with a trailing chevron icon in the
  # direction of the menu's placement and a list menu.
  #
  # The trigger and menu can be customized through their respective slots.
  class Dropdown < Gustwave::Component
    # The id of the menu element shown when the trigger is activated
    attr_reader :menu_id

    # The component class rendered by the +menu+ slot, as a class or class name.
    #
    # Set it to a subclass of Gustwave::Dropdowns::Menus::List to add item
    # types without subclassing Dropdown. Set it whenever Dropdown loads, and
    # use a class name, so both survive code reloading:
    #
    #   class MyList < Gustwave::Dropdowns::Menus::List
    #     extend_slot :items, types: { avatar: MyAvatarItem }
    #   end
    #
    #   # config/initializers/gustwave.rb, for every dropdown
    #   Rails.autoloaders.main.on_load("Gustwave::Dropdown") do |dropdown, _abspath|
    #     dropdown.list_menu_class = "MyList"
    #   end
    #
    #   class MyDropdown < Gustwave::Dropdown
    #     self.list_menu_class = "MyList" # only this subclass
    #   end
    class_attribute :list_menu_class,
                    instance_writer: false,
                    instance_predicate: false,
                    default: "Gustwave::Dropdowns::Menus::List"

    # Use the +trigger+ slot, with +with_trigger_generic+ or +with_trigger_component+, to fully customize the
    # visual appearance of the trigger element
    #
    # When the trigger slot is absent, a button with a trailing icon (chevron)
    # will be rendered by default.
    #
    # The generic trigger type, +with_trigger_generic+, takes any block and surrounds it with an HTML
    # element carrying the trigger's +data-dropdown-*+ attributes. Configure
    # these attributes through the +Dropdown+ main constructor. Modify the
    # surrounding HTML element through the +options+ hash and the +tag+
    # parameter.
    #
    # === Example
    # Renders the dropdown trigger as a badge with the default configuration:
    #
    #   <%= render Gustwave::Dropdown.new do %>
    #     <%= it.with_trigger_generic do %>
    #       <%= render Gustwave::Badge.new("Dropdown badge") %>
    #     <% end %>
    #   <% end %>
    #
    # The +with_trigger_component+ setter allows you to render a fully custom trigger
    # component. Your component should be a subclass of Gustwave::Dropdowns::Triggers::Base
    # or handle the configuration hash passed to the constructor to generate the
    # required +data-dropdown-*+ attributes.
    #
    # @param options [Hash] additional HTML attributes passed to the surrounding HTML element, and its +tag+, see Gustwave::Dropdowns::Triggers::Generic.
    renders_one_extensible :trigger, types: {
      generic: ->(**options) {
        config = configure_html_attributes(options, **trigger_config)
        Gustwave::Dropdowns::Triggers::Generic.new(**config)
      },
      # Use the +with_trigger_component+ setter when you want to call a custom trigger
      # component
      #
      # In most cases the generic +with_trigger_generic+ setter is sufficient.
      #
      # @param args [Array] the arguments to pass to the component.
      # @param component [Class] the component to render as the trigger. Should be a subclass of Gustwave::Dropdowns::Triggers::Base to handle the trigger's +data-dropdown-*+ attributes.
      # @param options [Hash] HTML attributes and the custom component's own keywords passed to the component.
      component: ->(*args, component: Gustwave::Dropdowns::Triggers::Button, **options) {
        config = configure_html_attributes(options, **trigger_config)
        component.new(*args, **config)
      }
    }

    # Use the +menu+ slot, with +with_menu_list+ or +with_menu_generic+, to render the dropdown menu
    #
    # Note: The +menu+ type slots are optional. The trigger will show any HTML
    # element that matches Gustwave::Dropdown#menu_id
    #
    # Premade menu types:
    # * +list+: renders a list menu with an optional header, a list of items, separators, submenus, and an optional footer.
    # * +generic+: renders a generic menu with an optional header, any block content, and an optional footer.
    #
    # @see Gustwave::Dropdowns::Menus::List
    # @see list_menu_class
    # @see Gustwave::Dropdowns::Menus::Generic
    renders_one_extensible :menu, types: {
      list: ->(content_for: nil, list_options: {}, **options) {
        config = configure_html_attributes(options, content_for:, id: menu_id)
        component = list_menu_class.to_s.constantize.new(**config)
        component.configure_list(**list_options) if list_options.present?
        component
      },
      generic: ->(text = nil, tag: :div, content_for: nil, **options) {
        config = configure_html_attributes(options, id: menu_id, tag:, content_for:)
        Gustwave::Dropdowns::Menus::Generic.new(text, **config)
      }
    }

    # @param text [String, nil] the text to appear on the dropdown button. Takes precedent over block content.
    # @param menu_id [String, nil] the id of the target element. If not provided, a random id will be generated.
    # @param icon [Symbol, nil] the icon identifier rendered as leading visual on the trigger button. Pass in +nil+ to not render an icon.
    # @param trailing_icon [Symbol, nil, false] the icon identifier rendered as trailing visual on the trigger button. Pass in +nil+ to automatically render a chevron icon pointing in the direction of +placement+. Pass in +false+ to not render a trailing icon.
    # @param inline [Boolean] whether to render the dropdown trigger with inline styling, so it can appear in a text block.
    # @param trigger_event [Symbol] the trigger event for the dropdown. Pass in :click (default) or :hover.
    # @param delay [Integer] the delay in milliseconds before the dropdown is shown.
    # @param placement [Symbol] the placement of the dropdown. Options: +auto+, +auto-start+, +auto-end+, +top+, +top-start+, +top-end+, +bottom+, +bottom-start+, +bottom-end+, +right+, +right-start+, +right-end+, +left+, +left-start+, +left-end+. See: https://popper.js.org/docs/v2/constructors/#options
    # @param offset_distance [Integer] the distance in pixels between the target and the dropdown in the +placement+ main axis.
    # @param offset_skidding [Integer] the distance in pixels between the target and the dropdown in the +placement+ secondary axis.
    # @param options [Hash] additional HTML attributes for the trigger element. The default trigger is a Gustwave::Button, so its own keywords (+theme+, +color+, +size+, +pill+, +tag+, +type+) pass through as well.
    def initialize(
      text = nil,
      menu_id: nil,
      icon: nil,
      trailing_icon: nil,
      inline: false,
      trigger_event: DEFAULT,
      delay: Gustwave::Dropdowns::Triggers::Base::DELAY_DEFAULT,
      placement: DEFAULT,
      offset_distance: Gustwave::Dropdowns::Triggers::Base::OFFSET_DISTANCE_DEFAULT,
      offset_skidding: Gustwave::Dropdowns::Triggers::Base::OFFSET_SKIDDING_DEFAULT,
      **options
    )
      @menu_id = menu_id || generate_random_id(prefix: "dropdown")
      @text = text
      @inline = inline
      @trigger_config = {
        menu_id: @menu_id,
        icon:,
        trailing_icon:,
        trigger_event:,
        delay:,
        placement:,
        offset_distance:,
        offset_skidding:,
        **options
      }
    end

    def call
      safe_join([ trigger || default_trigger, menu ])
    end

    private
    attr_reader :trigger_config, :text, :inline

    def default_trigger
      component =
        if inline?
          Gustwave::Dropdowns::Triggers::InlineButton
        else
          Gustwave::Dropdowns::Triggers::Button
        end

      render component.new(**trigger_config) do
        text_or_content(text)
      end
    end

    def inline?
      inline
    end
  end
end
