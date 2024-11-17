# frozen_string_literal: true

module Form
  class SubmitButtonGroupComponent < ApplicationComponent
    renders_many :buttons, types: {
      regular: ->(text, **options) {
        options = parse_options(options)
        Form::ButtonComponent.new(**options).with_content(text)
      },
      delete: ->(text, target_modal_id:) {
        DeleteConfirm::ButtonComponent.new(text: text, target_modal_id: target_modal_id)
      }
    }
    alias button with_button_regular
    alias delete_button with_button_delete

    def initialize(form, render_if: true)
      @form = form
      @is_rendered = render_if
    end

    def render?
      @is_rendered
    end

    private

    def parse_options(options)
      options.stringify_keys!
      options["name"] = options.delete("name") || "#{@form.object_name}[submit_type]"
      options["value"] = options.delete("value") || "save"
      options
    end
  end
end
