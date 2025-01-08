# frozen_string_literal: true

module Form
  class SubmitButtonGroupComponent < TendrilTasks::Component
    renders_many :buttons, types: {
      regular: ->(text, **options) {
        options = build_options(options)
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

    def build_options(options)
      options.deep_symbolize_keys!
      options[:name] = options.delete(:name) || "#{@form.object_name}[submit_type]"
      options[:value] = options.delete(:value) || "save"
      options
    end
  end
end
