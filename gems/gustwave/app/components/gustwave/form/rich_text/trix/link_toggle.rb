# frozen_string_literal: true

module Gustwave
  module Form
    module RichText
      module Trix
        class LinkToggle < Gustwave::Component
          def initialize(form, **options)
            @form = form
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
            @options.merge!(
              @popover.trigger_options(trigger: :click,
                                       placement: :"top-end"))
          end
        end
      end
    end
  end
end
