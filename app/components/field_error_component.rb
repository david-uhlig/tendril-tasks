# frozen_string_literal: true

class FieldErrorComponent < ApplicationComponent
  def initialize(obj_with_errors = nil, error_field = nil)
    @errors = obj_with_errors&.errors
    @error_field = error_field
  end

  def has_errors?
    @errors.any? && @error_field.present? && @errors[@error_field].present?
  end
end
