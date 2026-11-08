# frozen_string_literal: true

module Gustwave
  # Use Clipboard to copy the text of an element to the clipboard with a
  # button, as in Flowbite's clipboard examples. For a few seconds after the
  # copy the button shows its copied state.
  #
  # +target_id+ is the id of the element the text is copied from, e.g. an
  # input. Pass the button's label as +text+ or as a block:
  #
  #   render Gustwave::Clipboard.new("Copy", target_id: "npm-install")
  #
  # The button is a Gustwave::Button of +theme+, so its +color+ and +size+
  # apply. Without a label it is icon-only, and its label is only read by
  # screen readers:
  #
  #   render Gustwave::Clipboard.new(target_id: "api-key", theme: :inline)
  #
  # +copied_text+ is the label of the copied state. Without a visible label,
  # it is read by screen readers only.
  #
  # Copy the content of an inner HTML or text element with +content_type+. Set
  # +html_entities+ to decode the HTML's entities into plain text, e.g. for a
  # code block:
  #
  #   render Gustwave::Clipboard.new("Copy code", target_id: "code", content_type: :inner_html, html_entities: true)
  #
  # A tooltip next to the button swaps its text too, see +with_tooltip+.
  #
  # Flowbite's JavaScript copies the text. The +gustwave--clipboard+ Stimulus
  # controller, which the component wires up itself, changes the states.
  #
  # @status alpha
  class Clipboard < Gustwave::Component
    CONTROLLER = "gustwave--clipboard"
    COPY_ACTION = "click->gustwave--clipboard#copied"
    # Every Flowbite clipboard button centers its states, which are spans.
    BUTTON_CLASS = "inline-flex items-center justify-center"
    CONTENT_TYPES = { inner_html: "innerHTML", text_content: "textContent" }.freeze

    # Where Flowbite reads the text from. The default, +:input+, is the value
    # of the target element.
    option :content_type, default: :input, values: %i[input inner_html text_content]

    # The label and icon of the default state.
    part :message, "inline-flex items-center gap-1.5"
    # The label and icon of the copied state.
    part :copied_message, "inline-flex items-center gap-1.5"
    # Both states' icon, the size of the icon beside the label.
    part :icon, "shrink-0 w-4.5 h-4.5"

    # Renders an icon beside the label in the default state. Set it with
    # +with_icon+. An icon-only button without a label renders a clipboard icon
    # by default.
    #
    #   render Gustwave::Clipboard.new("Copy", target_id: "npm-install") do |clipboard|
    #     clipboard.with_icon(:clipboard)
    #   end
    #
    # @param name [Symbol] The icon to use. Defaults to +:clipboard+.
    # @param theme [Symbol] The icon theme. Defaults to +:solid+, as Flowbite's.
    # @param options [Hash] Additional HTML options passed to the icon component.
    renders_one_extensible :icon, ->(name = :clipboard, theme: :solid, **options) {
      clipboard_icon(name, theme:, **options)
    }

    # Renders an icon beside the label in the copied state. Set it with
    # +with_copied_icon+. Defaults to a check icon.
    #
    #   render Gustwave::Clipboard.new("Copy", target_id: "npm-install") do |clipboard|
    #     clipboard.with_copied_icon(:check, theme: :outline)
    #   end
    #
    # @param name [Symbol] The icon to use. Defaults to +:check+.
    # @param theme [Symbol] The icon theme. Defaults to +:outline+.
    # @param options [Hash] Additional HTML options passed to the icon component.
    renders_one_extensible :copied_icon, ->(name = :check, theme: :outline, **options) {
      clipboard_icon(name, theme:, **options)
    }

    # Renders a tooltip next to the button, as Flowbite's tooltips. The button
    # gets the tooltip's trigger attributes, and the tooltip's text swaps to
    # +copied_text+ when the text is copied. Renders no tooltip unless set.
    #
    #   render Gustwave::Clipboard.new(target_id: "npm-install") do |clipboard|
    #     clipboard.with_tooltip(placement: :bottom, copied_text: "Copied to clipboard")
    #   end
    #
    # @param text [String, nil] The tooltip's text in the default state. Defaults to a localized "Copy to clipboard".
    # @param copied_text [String, nil] The tooltip's text in the copied state. Defaults to a localized "Copied!".
    # @param placement [Symbol] Where the tooltip sits relative to the button, see Gustwave::Tooltip. Defaults to its default.
    # @param trigger_event [Symbol] +:hover+ or +:click+, what shows the tooltip. Defaults to +:hover+.
    # @param options [Hash] Additional HTML options and options of the tooltip, e.g. +color+.
    renders_one_extensible :tooltip, ->(text = nil, copied_text: nil, placement: DEFAULT, trigger_event: DEFAULT, **options) {
      @tooltip_id = options.delete(:id).presence || generate_random_id(prefix: "clipboard-tooltip")
      @tooltip_trigger = { placement:, trigger_event: }

      # The states are added in before_render: the slot can be set before
      # render, when translations aren't available yet.
      @tooltip_texts = { text:, copied_text: }
      Gustwave::Tooltip.new(id: @tooltip_id, **options)
    }

    # The icon of an icon-only button, which has no label. Public, because
    # ViewComponent only finds +default_<slot>+ methods that are public.
    def default_icon
      build_slot_icon unless visible_label
    end

    # The check icon of the copied state. Public, see +default_icon+.
    def default_copied_icon
      build_slot_copied_icon
    end

    # @param text [String, nil] Text to display on the button. Takes precedence over block content. Without a label, the button is icon-only.
    # @param target_id [String] The id of the element the text is copied from, without +#+.
    # @param copied_text [String, nil] The label of the copied state. Defaults to a localized "Copied!".
    # @param theme [Symbol] The Gustwave::Button theme of the button. Defaults to :default.
    # @param content_type [Symbol] What is copied: +:input+ for the value of the target, +:inner_html+ for its inner HTML, or +:text_content+ for its text. Defaults to +:input+.
    # @param html_entities [Boolean] Whether HTML entities in the copied text are decoded into plain text. Defaults to +false+.
    # @param reset_after [Integer] Milliseconds before the button returns to its default state. Zero or less keeps the copied state.
    # @param message_options [Hash] HTML attributes for the default state's label, e.g. +class+.
    # @param copied_message_options [Hash] HTML attributes for the copied state's label, e.g. +class+.
    # @param options [Hash] HTML attributes and button options, such as +color+ and +size+, forwarded to the button. Its +data+ and +aria+ hashes merge with the defaults.
    def initialize(text = nil,
                   target_id:,
                   copied_text: nil,
                   theme: :default,
                   content_type: DEFAULT,
                   html_entities: false,
                   reset_after: 2000,
                   message_options: {},
                   copied_message_options: {},
                   **options)
      @text = text
      @target_id = target_id
      @copied_text = copied_text
      @theme = theme
      @html_entities = ActiveModel::Type::Boolean.new.cast(html_entities)
      @reset_after = reset_after
      @message_options = message_options
      @copied_message_options = copied_message_options
      @options = options

      select_options(content_type:)
    end

    def before_render
      tooltip.with_content(tooltip_states) if tooltip?
      @button = Gustwave::Button.for(@theme).new(states, **button_attributes)
    end

    def call
      safe_join([ render(@button), (tooltip if tooltip?) ].compact)
    end

    private

    def clipboard_icon(name, theme:, **options)
      # The label says what the button does, so the icon is decorative.
      options = configure_html_attributes(options, aria: { hidden: true })
      Gustwave::Icon.new(name, theme:, **attributes_for(:icon, options))
    end

    # The label of the default state, or +nil+ when it has none. Evaluates the
    # block, so call it at render time.
    def visible_label
      text_or_content(@text).presence
    end

    # Both states, in the button's content. The copied state's label is
    # visible only when the default state's is, so an icon-only button stays
    # icon-only in both states.
    def states
      safe_join([
        tag.span(safe_join([ icon, default_label ].compact), **message_attributes),
        tag.span(safe_join([ copied_icon, copied_label ].compact), **copied_attributes)
      ])
    end

    def default_label
      visible_label || sr_only(t(".copy"))
    end

    def copied_label
      text = @copied_text.presence || t(".copied")
      visible_label ? text : sr_only(text)
    end

    def message_attributes
      attributes_for(:message, configure_html_attributes(@message_options, data: { "gustwave--clipboard-target": "message" }))
    end

    # Hidden until the copy, and the Stimulus controller toggles it with the
    # default state. The +hidden+ attribute, not a class, because the
    # +inline-flex+ class would win over a +hidden+ one.
    def copied_attributes
      attributes_for(:copied_message, configure_html_attributes(@copied_message_options, hidden: true,
                                                                data: { "gustwave--clipboard-target": "copiedMessage" }))
    end

    def tooltip_states
      safe_join([
        clipboard_tooltip_state(@tooltip_texts[:text] || t(".copy"), copied: false),
        clipboard_tooltip_state(@tooltip_texts[:copied_text] || t(".copied"), copied: true)
      ])
    end

    def clipboard_tooltip_state(text, copied:)
      tag.span(text, hidden: copied, data: { "gustwave--clipboard-target": copied ? "copiedMessage" : "message" })
    end

    def button_attributes
      attributes = merge_data_tokens(@options.deep_symbolize_keys, controller: CONTROLLER, action: COPY_ACTION)
      if tooltip?
        attributes = tooltip.trigger_options(**@tooltip_trigger, **attributes).symbolize_keys
      end
      configure_html_attributes(attributes, class: BUTTON_CLASS, data: button_data)
    end

    def button_data
      {
        "copy-to-clipboard-target": @target_id,
        "copy-to-clipboard-content-type": CONTENT_TYPES[option_value(:content_type)],
        "copy-to-clipboard-html-entities": ("true" if @html_entities),
        "gustwave--clipboard-reset-after-value": @reset_after,
        "gustwave--clipboard-tooltip-id-value": (@tooltip_id if tooltip?)
      }.compact
    end
  end
end
