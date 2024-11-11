# frozen_string_literal: true

module Form
  # Displays a label, the currently selected coordinators, a button to open the edit modal, and a modal to change
  # the selected coordinators
  #
  # The modal is rendered through `content_for :modal` to ensure it appears outside any containing form, as it
  # includes its own form and this component is used within other forms.
  #
  # == Usage:
  # Within a Rails view, you can render the component with:
  #
  #   <%= render Form::CoordinatorPickerComponent.new(form, :coordinators, "Coordinators", { class: "custom-class" })) %>
  class CoordinatorPickerComponent < ApplicationComponent
    def initialize(form, attribute, label = nil, options = {})
      @form = form
      @attribute = attribute
      @label = label
      @options = options
    end
  end
end
