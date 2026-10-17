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

    # Use the +trigger+ or +trigger_component+ slot to fully customize the
    # visual appearance of the trigger element
    #
    # When the trigger slot is absent, a button with a trailing icon (chevron)
    # will be rendered by default.
    #
    # The generic +trigger+ slot takes any block and surrounds it with an HTML
    # element carrying the trigger's +data-dropdown-*+ attributes. Configure
    # these attributes through the +Dropdown+ main constructor. Modify the
    # surrounding HTML element through the +options+ hash and the +tag+
    # parameter.
    #
    # === Example
    # Renders the dropdown trigger as a badge with the default configuration:
    #
    #   <%= render Gustwave::Dropdown.new do %>
    #     <%= it.trigger do %>
    #       <%= render Gustwave::Badge.new("Dropdown badge") %>
    #     <% end %>
    #   <% end %>
    #
    # The +trigger_component+ slot allows you to render a fully custom trigger
    # component. Your component should be a subclass of Gustwave::Dropdowns::Triggers::Base
    # or handle the configuration hash passed to the constructor to generate the
    # required +data-dropdown-*+ attributes.
    #
    # @param options [Hash] additional HTML attributes passed to the surrounding HTML element, and its +tag+, see Gustwave::Dropdowns::Triggers::Generic.
    renders_one_extensible :trigger_slot, types: {
      generic: ->(**options) {
        config = configure_html_attributes(options, **trigger_config)
        Gustwave::Dropdowns::Triggers::Generic.new(**config)
      },
      # Use the +trigger_component+ slot when want to call a custom trigger
      # component
      #
      # In most cases the generic +trigger+ slot is sufficient.
      #
      # @param args [Array] the arguments to pass to the component.
      # @param component [Class] the component to render as the trigger. Should be a subclass of Gustwave::Dropdowns::Triggers::Base to handle the trigger's +data-dropdown-*+ attributes.
      # @param options [Hash] additional config options and HTML attributes passed to the component.
      component: ->(*args, component: Gustwave::Dropdowns::Triggers::Button, **options) {
        config = configure_html_attributes(options, **trigger_config)
        component.new(*args, **config)
      }
    }
    alias trigger with_trigger_slot_generic
    alias trigger_component with_trigger_slot_component

    # Use the +menu+ or +generic_menu+ slot to render the dropdown menu
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
    renders_one_extensible :menu_slot, types: {
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
    alias menu with_menu_slot_list
    alias generic_menu with_menu_slot_generic

    # @param text [String, nil] the text to appear on the dropdown button. Takes precedent over block content.
    # @param menu_id [String, nil] the id of the target element. If not provided, a random id will be generated.
    # @param icon [Symbol, nil] the icon identifier rendered as leading visual on the trigger button. Pass in +nil+ to not render an icon.
    # @param trailing_icon [Symbol, nil, false] the icon identifier rendered as trailing visual on the trigger button. Pass in +nil+ to automatically render a chevron icon pointing in the direction of +placement+. Pass in +false+ to not render a trailing icon.
    # @param inline [Boolean] whether to render the dropdown trigger with inline styling, so it can appear in a text block.
    # @param options [Hash] additional HTML and component options passed to the trigger component, e.g. +trigger_event+, +delay+, +placement+, +offset_distance+ and +offset_skidding+, see Gustwave::Dropdowns::Triggers::Base.
    def initialize(
      text = nil,
      menu_id: nil,
      icon: nil,
      trailing_icon: nil,
      inline: false,
      **options
    )
      @menu_id = menu_id || generate_random_id(prefix: "dropdown")
      @text = text
      @inline = inline
      @trigger_config = {
        menu_id: @menu_id,
        icon:,
        trailing_icon:,
        **options
      }
    end

    def call
      safe_join([ trigger_slot || default_trigger, menu_slot ])
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
