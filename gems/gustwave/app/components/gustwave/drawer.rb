# frozen_string_literal: true

module Gustwave
  # An off-canvas panel that slides in from an edge of the screen, driven by
  # Flowbite's drawer JavaScript.
  #
  # The drawer element initialises itself by carrying
  # +data-drawer-target="<its own id>"+ together with the config data
  # attributes. This deviates from Flowbite's documented markup, where the
  # trigger carries +data-drawer-target+, but Flowbite's +initDrawers()+ reads
  # the config from the +[data-drawer-target]+ element, so it works. The
  # +trigger_options+ never emit +data-drawer-target+, since a second one would
  # create a duplicate instance.
  #
  # +edge+ gives a bottom drawer a rounded top edge and leaves a gap of
  # +edge_offset+ at the bottom, e.g. for a tab bar. It is only valid with
  # +placement: :bottom+ and raises +ArgumentError+ otherwise when
  # Gustwave.strict?, and is dropped otherwise.
  #
  #   <% drawer = Gustwave::Drawer.new(id: "info", placement: :right) %>
  #   <%= render Gustwave::Button.new("Show", **drawer.trigger_options) %>
  #   <%= render drawer do |d| %>
  #     <% d.with_header("Info", icon: :info_circle) %>
  #     …body…
  #   <% end %>
  class Drawer < Gustwave::Component
    EDGE_OFFSET_DEFAULT = "bottom-[60px]"

    attr_reader :id

    option :action, default: :toggle, values: %i[toggle show hide]

    base "fixed z-40 p-4 transition-transform bg-white dark:bg-gray-800"

    variant :placement, default: :left, values: {
      left: "top-0 left-0 h-screen w-80 overflow-y-auto -translate-x-full",
      right: "top-0 right-0 h-screen w-80 overflow-y-auto translate-x-full",
      top: "top-0 left-0 right-0 w-full -translate-y-full",
      bottom: "bottom-0 left-0 right-0 w-full overflow-y-auto translate-y-full"
    }

    toggle :edge, "p-0 border-t border-gray-200 rounded-t-lg dark:border-gray-700"

    renders_one_extensible :header, ->(text = nil, **options, &block) {
      Gustwave::DrawerHeader.new(text, drawer_id: id, edge: edge?, **options)
    }

    # @param text [String, nil] Text to display within the drawer. Takes precedence over block content.
    # @param id [String, nil] The drawer's id, which the trigger targets. Generated when missing.
    # @param placement [Symbol] The edge the drawer slides in from: :left, :right, :top or :bottom. Defaults to :left.
    # @param backdrop [Boolean] Whether a backdrop covers the page while the drawer is open. Defaults to +true+.
    # @param body_scrolling [Boolean] Whether the page scrolls while the drawer is open. Defaults to +false+.
    # @param edge [Boolean] Whether a bottom drawer has a rounded top edge and a gap at the bottom. Only valid with placement: :bottom. Defaults to +false+.
    # @param edge_offset [String] The Tailwind class for the gap at the bottom of an edge drawer. Defaults to +bottom-[60px]+.
    # @param options [Hash] Additional HTML options passed to the component.
    def initialize(text = nil, id: nil, placement: DEFAULT, backdrop: true, body_scrolling: false,
                   edge: false, edge_offset: EDGE_OFFSET_DEFAULT, **options)
      @id = id || generate_random_id(prefix: "drawer")
      @text = text
      @backdrop = ActiveModel::Type::Boolean.new.cast(backdrop) != false
      @body_scrolling = ActiveModel::Type::Boolean.new.cast(body_scrolling) == true
      @edge_offset = edge_offset
      @options = options.symbolize_keys

      edge = ActiveModel::Type::Boolean.new.cast(edge) == true
      if edge && option_value(:placement, placement:) != :bottom
        raise ArgumentError, "Gustwave::Drawer's edge is only valid with placement: :bottom" if Gustwave.strict?

        edge = false
      end

      select_options(placement:, edge:)
    end

    def before_render
      options = @options.merge(
        id: @id,
        tabindex: "-1",
        "data-drawer-target": @id,
        "data-drawer-placement": option_value(:placement),
        "data-drawer-backdrop": @backdrop.to_s,
        "data-drawer-body-scrolling": @body_scrolling.to_s
      )
      if edge?
        options[:"data-drawer-edge"] = "true"
        options[:"data-drawer-edge-offset"] = @edge_offset
      end
      options[:"aria-labelledby"] = "#{@id}-title" if header?

      @config = attributes_for(options)
      # Appended after merging, outside TailwindMerge: it would drop +bottom-0+
      # in favour of the offset. Flowbite's JS removes the offset class on
      # open, which leaves the drawer with no +bottom+, so it is not merged.
      @config[:class] = [ @config[:class], @edge_offset ].compact_blank.join(" ") if edge?
    end

    def call
      tag.div(**@config) do
        safe_join([ header, text_or_content(text) ].compact)
      end
    end

    # Returns the HTML attributes that attach the trigger to the drawer.
    #
    # The trigger's +action+ (+:toggle+, +:show+ or +:hide+) decides which
    # +data-drawer-*+ attribute it carries. The drawer's own attributes take
    # precedence over any caller attribute with the same name, so the trigger
    # never ends up with duplicate keys. A trigger that opens or closes the
    # drawer, i.e. +:toggle+ or +:show+, points its +aria-controls+ at the
    # drawer, replacing the trigger's own, and announces a +dialog+. A +:hide+
    # trigger gets no ARIA attributes. The trigger's other +attributes+ are
    # returned as they are.
    #
    #   <%= link_to "Docs", docs_path, **drawer.trigger_options(class: "underline", data: { controller: "x" }) %>
    #
    # @param action [Symbol] What the trigger does: :toggle, :show or :hide. Defaults to :toggle.
    # @param attributes [Hash] the trigger's own HTML attributes.
    def trigger_options(action: DEFAULT, **attributes)
      drawer_keys = %w[data-drawer-target data-drawer-toggle data-drawer-show data-drawer-hide]
      options = attributes.reject { |key, _| drawer_keys.include?(key.to_s) }
      action = option_value(:action, action:)
      options["data-drawer-#{action}"] = @id
      unless action == :hide
        options = without_controls(options)
        options["aria-controls"] = @id
        options["aria-haspopup"] = "dialog"
      end
      options
    end

    # Returns the trigger's HTML attributes for the drawer with the given +id+.
    #
    #   <%= render Gustwave::Button.new("Show", **Gustwave::Drawer.trigger_options("info")) %>
    def self.trigger_options(id, **kwargs)
      new(id:).trigger_options(**kwargs)
    end

    private

    attr_reader :text

    def edge?
      option_value(:edge)
    end
  end
end
