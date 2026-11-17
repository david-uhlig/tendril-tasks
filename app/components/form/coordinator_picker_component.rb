# frozen_string_literal: true

module Form
  # Displays a fieldset with a legend, the currently selected coordinators, a button to open the edit modal, and a modal to change
  # the selected coordinators
  #
  # The modal is rendered through `content_for :modal` to ensure it appears outside any containing form, as it
  # includes its own form and this component is used within other forms.
  #
  # == Usage:
  # Within a Rails view, you can render the component with:
  #
  #   <%= render Form::CoordinatorPickerComponent.new(form, :coordinators, "Coordinators", { class: "custom-class" }) %>
  class CoordinatorPickerComponent < TendrilTasks::Component
    def initialize(form, attribute, label = nil, options = {})
      @form = form
      @attribute = attribute
      @label = label
      @options = options
    end

    private

    # Without a label the fieldset's legend defaults to the attribute's translated name.
    def label_option = @label.nil? ? {} : { label: @label }
  end
end
