# frozen_string_literal: true

module Gustwave
  module Form
    module RichText
      module Trix
        # @status alpha
        class LinkToggle < Gustwave::Component
          # @param form [ActionView::Helpers::FormBuilder, nil] the editor's form builder, as the toolbar passes it.
          # @param disabled [Boolean] whether the toolbar button is disabled. Defaults to +false+.
          # @param options [Hash] the arguments and HTML attributes of the toolbar button.
          def initialize(form, disabled: false, **options)
            @form = form
            @disabled = disabled
            @options = options
          end

          def before_render
            @popover = Gustwave::Popover.new(
              data: {
                "trix-dialog": "href",
                "trix-dialog-attribute": "href"
              },
              class: "mx-8"
            )
            @options = @popover.trigger_options(trigger_event: :click,
                                                placement: :"top-end",
                                                disabled: @disabled,
                                                **@options)
          end
        end
      end
    end
  end
end
