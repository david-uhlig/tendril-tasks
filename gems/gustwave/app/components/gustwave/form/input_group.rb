# frozen_string_literal: true

module Gustwave
  module Form
    # Use InputGroup to render a control with addons attached beside it: a
    # text or an icon, a button or a dropdown, with joined corners. It renders
    # in the +control+ slot of Gustwave::Form::Field, which then labels its
    # one control, or on its own.
    #
    #   <%= render Gustwave::Form::Field.new(:username, form: f) do |field| %>
    #     <% field.with_control_input_group(size: :lg) do |group| %>
    #       <% group.with_leading_addon_text("@") %>
    #       <% group.with_control_input %>
    #     <% end %>
    #   <% end %>
    #
    #   <%= render Gustwave::Form::InputGroup.new do |group| %>
    #     <% group.with_control_input(name: "domain", aria: { label: "Domain" }) %>
    #     <% group.with_trailing_addon_text(".com") %>
    #   <% end %>
    #
    # The group passes the field's context (attribute, form, ID, validation
    # state and +aria-describedby+) on to its control, so the label's +for+,
    # +aria-describedby+ and +aria-invalid+ stay on the one real control. It
    # also tells the control which corners are joined, and its own +size+
    # unless the control has one. The addon drops its seam border, so the
    # control's border, and with it the validation color, stays whole. A
    # divider thicker than the border, or in another color, is a class on the
    # addon: <tt>with_leading_addon_text("@", class: "border-e-2")</tt>.
    #
    # Only the control's attribute counts. The addons hold no value of their
    # own: an addon that is a form element for another attribute doesn't
    # belong to the group.
    #
    # @status alpha
    class InputGroup < Gustwave::Component
      part :root, "flex"

      # The size of the addons, and of the control unless it has its own. Each
      # addon is as high as the control or higher, because the row stretches.
      option :size, default: :md, values: %i[sm md lg]

      # The button size with the padding and text of each group size, for a
      # button addon of a theme other than Gustwave::Form::InputGroups::Button.
      derive :button_size, from: :size, values: { sm: :xs, md: :md, lg: :lg }

      # Classes that attach a themed button to the control. +rounded-none+
      # makes TailwindMerge drop the theme's own rounding, and the border
      # facing the control goes so the seam isn't doubled by bordered themes.
      part :addon_button, "shrink-0 z-10 inline-flex items-center justify-center rounded-none"

      # The side of the control an addon button sits on, set for each addon by
      # the group. Squares off the corner facing the control.
      variant :side, part: :addon_button, default: :leading, allow_none: false, internal: true, values: {
        leading: "rounded-s-lg border-e-0",
        trailing: "rounded-e-lg border-s-0"
      }

      # The control the addons are attached to. Its corners are joined to the
      # addons on its own.
      #
      # * +input+: a Gustwave::Form::Input, built with the given arguments.
      # * +select+: a Gustwave::Form::Select, built with the given arguments.
      # * +renderable+: any component. One that implements +apply_slot_context+
      #   receives what Gustwave::Form::Field passes, as Gustwave::Form::Input
      #   does, and +joined+ and +size+. It keeps its corners unless it joins
      #   them itself.
      #
      #   <% group.with_control_input(type: :email, placeholder: "name@acme.com") %>
      #   <% group.with_control_select(choices: %w[AM PM]) %>
      #   <% group.with_control_renderable(MyCombobox.new) %>
      renders_one_extensible :control, types: {
        input: ->(*args, **options) { Gustwave::Form::Input.new(*args, **options) },
        select: ->(*args, **options) { Gustwave::Form::Select.new(*args, **options) }
      }, renderable: :control_context

      # The addon before the control.
      #
      # * +text+: a Gustwave::Form::InputGroups::Text, with the text or a block, e.g. with a visual.
      # * +button+: a Gustwave::Button, in the +:default+ theme unless given a +theme+. It takes the options of the theme, e.g. <tt>theme: :outline, color: :green</tt>, and <tt>theme: :input_addon</tt> gives the grey addon look of Gustwave::Form::InputGroups::Button.
      # * +dropdown+: a Gustwave::Dropdown whose trigger is a Gustwave::Form::InputGroups::Button, unless given another +theme+. Its menu sits in the row beside the trigger.
      # * +generic+: the block, as it is.
      # * +renderable+: any component. One that implements +apply_slot_context+ receives +side+ and +size+.
      #
      #   <% group.with_leading_addon_text("@") %>
      #   <% group.with_leading_addon_text { |addon| addon.with_leading_visual_icon(:user_circle) } %>
      #   <% group.with_leading_addon_button("Copy", type: :button) %>
      #   <% group.with_leading_addon_button("New", theme: :outline, color: :green) %>
      #   <% group.with_leading_addon_dropdown("All categories") { |dropdown| dropdown.with_menu_list { ... } } %>
      #   <% group.with_leading_addon_generic { tag.span("Any markup") } %>
      #   <% group.with_leading_addon_renderable(MyAddon.new) %>
      renders_one_extensible :leading_addon, types: {
        text: ->(*args, **options) { addon_text(:leading, *args, **options) },
        button: ->(*args, **options) { addon_button(:leading, *args, **options) },
        dropdown: ->(*args, **options) { addon_dropdown(:leading, *args, **options) },
        generic: ->(&block) { block&.call }
      }, renderable: :leading_addon_context

      # The addon after the control. It takes the types of +leading_addon+.
      #
      #   <% group.with_trailing_addon_text(".com") %>
      #   <% group.with_trailing_addon_button("Copy", type: :button) %>
      #   <% group.with_trailing_addon_dropdown("AM") { |dropdown| dropdown.with_menu_list { ... } } %>
      renders_one_extensible :trailing_addon, types: {
        text: ->(*args, **options) { addon_text(:trailing, *args, **options) },
        button: ->(*args, **options) { addon_button(:trailing, *args, **options) },
        dropdown: ->(*args, **options) { addon_dropdown(:trailing, *args, **options) },
        generic: ->(&block) { block&.call }
      }, renderable: :trailing_addon_context

      # @param size [Symbol] the size of the addons, and of the control unless it has its own +size+. Defaults to +:md+. Valid values are +:sm+, +:md+ and +:lg+.
      # @param options [Hash] the HTML attributes of the +<div>+.
      def initialize(size: DEFAULT, **options)
        select_options(size:)
        @options = options
      end

      # Called by Gustwave::Form::Field with the context for the control,
      # which the group passes on once it has the control: the field asks the
      # group for the control's ID before the group renders.
      #
      # @param context [Hash] the context of the field, see Gustwave::Form::BoundControl#apply_slot_context. +slot+ is left out.
      # @return [void]
      def apply_slot_context(slot: nil, **context)
        @context = context
        apply_context_to_control
      end

      # The ID of the control: the caller's own, the one of the context, or
      # Rails' ID for the bound attribute.
      #
      # @return [String, nil]
      def html_id
        control = control_if_set
        return control.html_id if control.respond_to?(:html_id)

        form, attribute = @context&.values_at(:form, :attribute)
        form.field_id(attribute) if form.present? && attribute.present?
      end

      # Whether the control is disabled.
      #
      # @return [Boolean]
      def disabled? = control_if_set.respond_to?(:disabled?) && control_if_set.disabled?

      # Whether the control is one of several for its attribute.
      #
      # @return [Boolean]
      def shares_attribute? = control_if_set.respond_to?(:shares_attribute?) && control_if_set.shares_attribute?

      def before_render
        content # evaluates the block, so the slots set in it are known
        apply_context_to_control
        @config = attributes_for(@options)
      end

      def call
        tag.div(**@config) do
          safe_join([ leading_addon, control, trailing_addon ].compact)
        end
      end

      private

      def control_if_set = (control if respond_to?(:control))

      # Passes the field's context, the joined edges and the size to the control.
      def apply_context_to_control
        control = control_if_set
        return unless control.respond_to?(:apply_slot_context)

        control.apply_slot_context(slot: :control, **control_context)
      end

      def control_context
        (@context || {}).merge(joined:, size: option_value(:size))
      end

      # The edges of the control with an addon, as the control's +joined+ variant names them.
      def joined
        case [ leading_addon?, trailing_addon? ]
        in [ true, true ] then :both
        in [ true, false ] then :start
        in [ false, true ] then :end
        else :none
        end
      end

      def leading_addon_context = { side: :leading, size: option_value(:size) }

      def trailing_addon_context = { side: :trailing, size: option_value(:size) }

      def addon_text(side, *args, **options)
        Gustwave::Form::InputGroups::Text.new(*args, side:, size: option_value(:size), **options)
      end

      def addon_button(side, *args, theme: :default, **options)
        Gustwave::Button.for(theme).new(*args, **addon_button_options(theme, side, options))
      end

      def addon_dropdown(side, *args, theme: :input_addon, **options)
        Gustwave::Dropdown.new(*args, theme:, **addon_button_options(theme, side, options))
      end

      # The options that attach a button of +theme+ to the control. The addon
      # theme takes the side and size itself. Any other theme gets the group's
      # size as its nearest button size, and the classes that square off the
      # corner facing the control, ahead of the caller's classes.
      def addon_button_options(theme, side, options)
        if Gustwave::Button.for(theme) <= Gustwave::Form::InputGroups::Button
          { side:, size: option_value(:size) }.merge(options)
        else
          { size: derived_value(:button_size) }.merge(options, class: classes(:addon_button, side:, class: options[:class]))
        end
      end
    end
  end
end
