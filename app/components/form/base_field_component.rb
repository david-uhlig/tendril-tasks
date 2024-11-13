# frozen_string_literal: true

module Form
  class BaseFieldComponent < ApplicationComponent
    def initialize(form, attribute, label = nil, error_field_attribute = nil, **options)
      @form = form
      @attribute = attribute
      @error_field_attribute = error_field_attribute || attribute
      @label = label
      @options = options
    end
  end
end
