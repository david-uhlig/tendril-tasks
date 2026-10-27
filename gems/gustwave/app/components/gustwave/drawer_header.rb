# frozen_string_literal: true

module Gustwave
  # The header of a +Gustwave::Drawer+, rendered through +drawer.with_header+.
  #
  # The header is a title that labels the drawer, plus a close button that
  # calls Flowbite's +drawer.hide()+ through +data-drawer-hide+. The close
  # button is not a +Gustwave::DismissButton+: +data-dismiss-target+ hides the
  # element without calling +drawer.hide()+, which leaves the backdrop and the
  # scroll lock behind.
  #
  # With +edge+, the header is the swipeable handle that toggles the drawer,
  # and it has no close button.
  #
  #   <% drawer = Gustwave::Drawer.new(id: "info", placement: :right) %>
  #   <%= render drawer do |d| %>
  #     <% d.with_header("Info", icon: :info_circle) %>
  #     …body…
  #   <% end %>
  class DrawerHeader < Gustwave::Component
    part :title, "inline-flex items-center mb-4 text-base font-semibold text-gray-500 dark:text-gray-400"
    part :title_icon, "w-4 h-4 me-2.5"
    part :close_button, "absolute top-2.5 end-2.5 w-8 h-8 inline-flex items-center justify-center rounded-lg text-sm text-gray-400 bg-transparent hover:bg-gray-200 hover:text-gray-900 dark:hover:bg-gray-600 dark:hover:text-white"
    part :handle, "p-4 cursor-pointer hover:bg-gray-50 dark:hover:bg-gray-700"
    part :handle_bar, "absolute w-8 h-1 -translate-x-1/2 bg-gray-300 rounded-lg top-3 left-1/2 dark:bg-gray-600"

    # Flowbite's edge drawer title has no bottom margin and a medium weight
    toggle :edge, "mb-0 font-medium", part: :title

    # @param text [String, nil] The title text. Takes precedence over block content.
    # @param drawer_id [String] The id of the drawer this header belongs to. The title's id is +"#{drawer_id}-title"+, which the drawer labels itself by, and the close button or handle targets the drawer.
    # @param close_button [Boolean] Whether a close button is rendered. Defaults to +true+. Ignored with +edge+.
    # @param icon [Symbol, nil] The icon rendered before the title, e.g. +:info_circle+. Defaults to no icon.
    # @param edge [Boolean] Whether the header is the swipeable handle of an edge drawer, which toggles the drawer instead of closing it. Defaults to +false+.
    # @param title_options [Hash] HTML attributes for the title. Its +class+ adds to the title's classes, and its +id+ is replaced by the title's id.
    # @param options [Hash] HTML attributes for the header's outermost element: the title, or the handle with +edge+. The +title_options+ win for the title.
    def initialize(text = nil, drawer_id:, close_button: true, icon: nil, edge: false, title_options: {}, **options)
      @text = text
      @drawer_id = drawer_id
      @close_button = close_button != false
      @icon = icon
      @title_options = title_options
      @options = options

      select_options(edge:)
    end

    def call
      if edge?
        handle_tag
      else
        safe_join([ title_tag, close_button_tag ].compact)
      end
    end

    private

    attr_reader :text

    def edge?
      option_value(:edge)
    end

    def title_id
      "#{@drawer_id}-title"
    end

    def title_tag
      # Without +edge+ the title is the outermost element, so it takes the
      # header's +options+ too. The drawer is labelled by this id.
      attrs = edge? ? attributes_for(:title, @title_options) : attributes_for(:title, @options.merge(@title_options))
      tag.h5(**attrs.merge(id: title_id)) do
        safe_join([ icon_tag, text_or_content(text) ].compact)
      end
    end

    def icon_tag
      return if @icon.blank?

      render Gustwave::Icon.new(@icon, theme: :solid, position: :standalone, class: classes(:title_icon))
    end

    def close_button_tag
      return unless @close_button && !edge?

      # The +data-drawer-hide+ trigger calls drawer.hide(), see the class docs.
      button = Gustwave::Button.for(:inline).new(sr_only(t(".close")), color: :none, class: classes(:close_button),
                                                 **Gustwave::Drawer.trigger_options(@drawer_id, action: :hide))
      button.with_leading_visual_icon(:close, stroke_width: 2, class: "w-6 h-6")
      render button
    end

    # The handle toggles the drawer, so it carries the toggle's ARIA
    # attributes. The +Gustwave::Drawer.trigger_options+ replace any caller
    # attribute with the same name, so the handle has no duplicate keys.
    #
    # TODO: Make the handle keyboard-accessible. Flowbite's handle is a click-only div, and a <button> can't contain the h5.
    def handle_tag
      attrs = Gustwave::Drawer.trigger_options(@drawer_id, action: :toggle, **attributes_for(:handle, @options))
      tag.div(**attrs) do
        safe_join([ tag.span(class: classes(:handle_bar)), title_tag ])
      end
    end
  end
end
