# frozen_string_literal: true

module Gustwave
  # A dialog that overlays the page, as in Flowbite's modals.
  #
  # Pass a +header+, a +body+ and a +footer+ slot, and block content after
  # them. The block content is appended after the slots, so a form can wrap a
  # Gustwave::ModalBody and a Gustwave::ModalFooter:
  #
  #   render Gustwave::Modal.new(id: "delete-task") do |modal|
  #     modal.with_header("Delete task")
  #     form_with(url: task_path(task), method: :delete) do
  #       concat render(Gustwave::ModalBody.new) { "Are you sure?" }
  #       concat render(Gustwave::ModalFooter.new) { safe_join([ cancel_button, delete_button ]) }
  #     end
  #   end
  #
  # Triggers open the modal and its buttons close it. Use +trigger_options+
  # with the modal's +id+. Triggers rendered apart from their modal use the
  # class method:
  #
  #   render Gustwave::Buttons::Default.new("Delete", **Gustwave::Modal.trigger_options("delete-task", action: :show))
  #
  # Flowbite's JavaScript is required, and so are the +gustwave--focus-trap+
  # and +gustwave--undismissible-modal+ Stimulus controllers. Gustwave ships
  # both, and the modal wires them up itself.
  #
  # Set +dismissible: false+ for a decision the user can't skip. Only the
  # modal's own hide buttons then close it, see +dismissible+ below.
  class Modal < Gustwave::Component
    attr_reader :id

    # See: https://flowbite.com/docs/components/modal/
    option :placement, default: :center, values: %i[
      top-left top-center top-right
      center-left center center-right
      bottom-left bottom-center bottom-right
    ]

    option :backdrop, default: :dynamic, values: %i[dynamic static]

    # Only picked in +trigger_options+.
    option :action, default: :toggle, values: %i[toggle show hide]

    base "hidden overflow-y-auto overflow-x-hidden fixed top-0 right-0 left-0 z-50 justify-center items-center w-full md:inset-0 h-[calc(100%-1rem)] max-h-full"

    part :dialog, "relative p-4 w-full max-h-full"
    part :content, "relative bg-white rounded-lg shadow-sm dark:bg-gray-700"

    variant :size, part: :dialog, default: :md, values: {
      sm: "max-w-md",
      md: "max-w-2xl",
      lg: "max-w-4xl",
      xl: "max-w-7xl"
    }

    # The flat trigger attributes that Flowbite reads, which +trigger_options+ replaces
    TRIGGER_KEYS = %w[data-modal-target data-modal-toggle data-modal-show data-modal-hide].freeze

    renders_one_extensible :header, ->(text = nil, **options) {
      Gustwave::ModalHeader.new(text, modal_id: id, close_button: dismissible?, **options)
    }

    renders_one_extensible :body, Gustwave::ModalBody

    renders_one_extensible :footer, Gustwave::ModalFooter

    # @param id [String, nil] The id the triggers target. Generated when blank.
    # @param size [Symbol] The width of the dialog: +:sm+, +:md+, +:lg+ or +:xl+. Defaults to +:md+.
    # @param placement [Symbol] Where the dialog sits in the viewport, e.g. +:center+ or +:"top-left"+. Defaults to +:center+.
    # @param backdrop [Symbol] +:dynamic+ closes the modal on an outside click, +:static+ doesn't. Defaults to +:dynamic+. A non-dismissible modal always has a static backdrop.
    # @param dismissible [Boolean] Whether the user can close the modal with its close button, Escape or an outside click. Defaults to +true+.
    #   With +false+, only the modal's own hide buttons (see +trigger_options+) close it: no close button in the header, no Escape, no outside click, whatever +backdrop+ is.
    #   Flowbite's JavaScript calls this +closable+. Gustwave doesn't pass it on, because Flowbite's +initFlowbite+ would discard it on every Turbo navigation.
    #   Use it only for decisions the user can't skip. While the modal is shown, Escape doesn't reach the modal's content.
    # @param options [Hash] Additional HTML attributes for the root element, e.g. +class+ or +data+.
    def initialize(id: nil,
                   size: DEFAULT,
                   placement: DEFAULT,
                   backdrop: DEFAULT,
                   dismissible: true,
                   **options)
      @id = id.presence || generate_random_id(prefix: "modal")
      @dismissible = ActiveModel::Type::Boolean.new.cast(dismissible) != false

      select_options(size:, placement:, backdrop: dismissible? ? backdrop : :static)
      @options = options
    end

    def dismissible?
      @dismissible
    end

    def before_render
      options = @options.deep_symbolize_keys
      options = merge_data_tokens(options, controller: [ "gustwave--focus-trap", ("gustwave--undismissible-modal" unless dismissible?) ].compact)

      root = {
        id:,
        tabindex: "-1",
        aria: { hidden: "true" },
        "data-modal-placement": option_value(:placement),
        "data-modal-backdrop": option_value(:backdrop)
      }
      root[:aria][:labelledby] = "#{id}-title" if header?

      @config = attributes_for(configure_html_attributes(options, **root))
    end

    def call
      tag.div(**@config) do
        tag.div(class: classes(:dialog)) do
          tag.div(class: classes(:content)) do
            slots_and_content(header, body, footer)
          end
        end
      end
    end

    # Returns the HTML attributes that make a trigger toggle, show or hide the
    # modal, like Popover's +trigger_options+. The trigger's own modal
    # attributes are dropped in favor of the modal's.
    #
    # +:toggle+ and +:show+ set the target and the action, and point
    # +aria-controls+ at the modal, replacing the trigger's own. +:hide+ sets
    # only the hide action, as Flowbite's close buttons carry no target. The
    # trigger's other attributes are returned as they are.
    #
    #   <%= button_tag "Delete", **modal.trigger_options(class: "underline", data: { controller: "x" }) %>
    #   <%= button_tag "Cancel", **modal.trigger_options(action: :hide) %>
    #
    # @param action [Symbol] +:toggle+, +:show+ or +:hide+. Defaults to +:toggle+.
    # @param attributes [Hash] the trigger's own HTML attributes.
    def trigger_options(action: DEFAULT, **attributes)
      options = attributes.reject { |key, _| TRIGGER_KEYS.include?(key.to_s) }
      action = option_value(:action, action:)

      if action == :hide
        options["data-modal-hide"] = id
      else
        options = without_controls(options)
        options["data-modal-target"] = id
        options["data-modal-#{action}"] = id
        options["aria-controls"] = id
        options["aria-haspopup"] = "dialog"
      end
      options
    end

    # Returns the trigger attributes of the modal with the given +id+, for a
    # trigger rendered apart from its modal, which knows only the id.
    def self.trigger_options(id, **kwargs) = new(id:).trigger_options(**kwargs)
  end
end
