# frozen_string_literal: true

module Form
  class SubmitButtonGroupComponent < ApplicationComponent
    BUTTON_CLASS = "w-full"

    renders_many :buttons, types: {
      regular: ->(text, options = {}) {
        options = parse_options(options)
        ButtonComponent.new(options, size: :large).with_content(text)
      },
      delete: ->(text, target_modal_id:) {
        DeleteConfirm::ButtonComponent.new(text: text, target_modal_id: target_modal_id)
      }
    }
    alias button with_button_regular
    alias delete_button with_button_delete

    def initialize(form, render_if: true)
      @form = form
      @render = render_if
    end

    def render?
      @render
    end

    private

    def parse_options(options)
      options[:class] = class_names(BUTTON_CLASS, options.delete(:class))
      options[:name] = options.delete(:name) || "#{@form.object_name}[submit_type]"
      options[:value] = options.delete(:value) || "save"
      options
    end
  end
end
