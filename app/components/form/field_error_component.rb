# frozen_string_literal: true

module Form
  class FieldErrorComponent < TendrilTasks::Component
    def initialize(obj_with_errors = nil, error_field = nil)
      @errors = []
      @errors = obj_with_errors&.errors if obj_with_errors.class < ActiveModel::Model
      @error_field = error_field
    end

    def has_errors?
      @errors.any? && @error_field.present? && @errors[@error_field].present?
    end
  end
end
