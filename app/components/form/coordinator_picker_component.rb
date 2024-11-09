# frozen_string_literal: true

module Form
  class CoordinatorPickerComponent < ApplicationComponent
    def initialize(form, attribute, label = nil, options = {})
      @form = form
      @attribute = attribute
      @label = label
      @options = options
    end
  end
end
