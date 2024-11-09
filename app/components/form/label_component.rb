# frozen_string_literal: true

module Form
  class LabelComponent < ApplicationComponent
    def initialize(form, attribute, text = nil)
      @form = form
      @attribute = attribute
      @text = text
    end

    def call
      classes = "block mb-2 text-sm font-medium text-gray-900 dark:text-white"
      if @text.present?
        @form.label @attribute, @text, class: classes
      else
        @form.label @attribute, class: classes
      end
    end
  end
end
