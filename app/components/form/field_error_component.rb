# frozen_string_literal: true

module Form
  class FieldErrorComponent < TendrilTasks::Component
    def initialize(obj_with_errors = nil, error_field = nil)
      @errors = obj_with_errors.try(:errors) || []
      @error_field = error_field
    end

    def has_errors?
      @errors.any? && @error_field.present? && @errors[@error_field].present?
    end

    # @return [String] the id of the element showing the error message
    def error_id
      "error-message-for-#{@error_field.to_param}"
    end
  end
end
