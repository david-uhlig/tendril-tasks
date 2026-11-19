# frozen_string_literal: true

module Gustwave
  module Form
    # Components of Gustwave::Form::InputGroup, the addons attached to its
    # control.
    module InputGroups
      # Use Text to render a gray addon with text or an icon beside the control
      # of a Gustwave::Form::InputGroup, e.g. a prefix like "@" or a unit. The
      # group sets its +side+ and +size+. It drops the border of the side
      # facing the control, so the control's border, and with it its
      # validation color, stays whole.
      #
      # Text takes the text as the argument or as the block. The block reaches
      # the visual slots, see Gustwave::Visuals:
      #
      #   <%= render Gustwave::Form::InputGroup.new do |group| %>
      #     <% group.with_leading_addon_text("@") %>
      #     <% group.with_control_input(name: "username") %>
      #   <% end %>
      #
      #   <%= render Gustwave::Form::InputGroup.new do |group| %>
      #     <% group.with_leading_addon_text { |addon| addon.with_leading_visual_icon(:user_circle) } %>
      #     <% group.with_control_input(name: "username") %>
      #   <% end %>
      #
      # @status alpha
      class Text < Gustwave::Component
        include Gustwave::Visuals

        renders_visuals :leading_visuals, :trailing_visuals

        self.visual_icon_theme = :solid

        base "inline-flex items-center text-gray-900 bg-gray-200 border border-gray-300 dark:bg-gray-600 dark:text-gray-400 dark:border-gray-600"

        # The icon fills the addon's text height, as Flowbite's 16px icon
        # does. Gustwave's icons leave a margin inside their box, so it is
        # 20px, with a negative margin that keeps the layout.
        part :visual, "h-5 w-5 -mx-0.5 text-gray-500 dark:text-gray-400"

        # The padding and text size per size of the group. The group's height
        # comes from the taller of the addon and the control.
        variant :size, default: :md, values: {
          sm: "px-3 py-2 text-xs",
          md: "px-3 py-2.5 text-sm",
          lg: "px-4 py-3 text-base"
        }

        # The side of the control the addon sits on, which the group selects
        # from the slot. The addon has no border on the side facing the
        # control.
        variant :side, default: :leading, allow_none: false, internal: true, values: {
          leading: "rounded-s-md border-e-0",
          trailing: "rounded-e-md border-s-0"
        }

        # @param text [String, nil] the text of the addon. Takes precedence over block content.
        # @param side [Symbol] the side of the control, +:leading+ or +:trailing+. The group sets it.
        # @param size [Symbol] the size, +:sm+, +:md+ or +:lg+. The group sets it to its own.
        # @param options [Hash] the HTML attributes of the +<span>+.
        def initialize(text = nil, side: DEFAULT, size: DEFAULT, **options)
          @text = text
          @options = options
          select_options(side:, size:)
        end

        def before_render
          select_options(has_visual: has_visual?)
          @config = attributes_for(@options)
        end

        def call
          tag.span(**@config) do
            slots_and_content(leading_visuals, text_or_content(@text), trailing_visuals, append_content: false)
          end
        end
      end
    end
  end
end
