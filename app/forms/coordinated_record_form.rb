# frozen_string_literal: true

# Shared behaviour of forms that edit a record with coordinators and a
# publication state, such as ProjectForm and TaskForm.
#
# Including classes declare the wrapped record with `coordinated_record`, which
# also defines a reader named after the record (`task` for Task):
#
#   class TaskForm
#     include CoordinatedRecordForm
#     coordinated_record Task
#   end
#
# ActiveModel::Model is included in this module rather than in an `included`
# block, so that this module's `initialize` comes before ActiveModel's and
# `super` reaches ActiveModel's initializer.
module CoordinatedRecordForm
  extend ActiveSupport::Concern
  include ActiveModel::Model

  class_methods do
    # Declares the record class wrapped by the form and defines the reader for
    # the record under its model name, e.g. `task` for Task.
    def coordinated_record(record_class)
      @coordinated_record_class = record_class
      define_method(record_class.model_name.element) { record }
    end

    def coordinated_record_class
      @coordinated_record_class
    end

    def human_attribute_name(attribute, **options)
      coordinated_record_class.human_attribute_name(attribute, **options)
    end
  end

  delegate :title, :title=,
           :description, :description=,
           to: :record

  def initialize(record_or_params = {})
    record_class = self.class.coordinated_record_class
    @record = record_or_params.is_a?(record_class) ? record_or_params : record_class.new
    super(record_or_params.is_a?(record_class) ? {} : record_or_params)
  end

  # Stages the coordinators until the form is saved. Ignores ids of users that
  # no longer exist, e.g. when a user was deleted while the form was open. An
  # empty list removes all coordinators, which fails validation on save.
  def coordinator_ids=(ids)
    users = User.includes(avatar_attachment: :blob).where(id: Array(ids).compact_blank).to_a
    @unsaved_coordinators =
      if users.map(&:id).sort == record.coordinator_ids.sort
        nil
      else
        users
      end
  end

  def coordinators
    @unsaved_coordinators || record.coordinators
  end

  def publish=(checkbox_value)
    should_publish = ActiveModel::Type::Boolean.new.cast(checkbox_value)

    if should_publish
      record.publish
    else
      record.unpublish
    end
  end

  def publish
    record.published?
  end

  def coordinator_options
    @coordinator_options ||= User.select(:id, :name)
                                 .includes(avatar_attachment: :blob)
                                 .excluding(coordinators)
                                 .limit(Coordinators::SearchesController::NUM_SEARCH_RESULTS)
                                 .to_a
  end

  def save
    has_changes = changed?
    @saved_changes = false

    record.class.transaction do
      # Update association records first so validations on them on the parent model have an effect
      record.coordinators = @unsaved_coordinators if coordinators_changed?
      record.save!
      @unsaved_coordinators = nil
      @saved_changes = has_changes

      true
    end
  rescue ActiveRecord::RecordInvalid
    errors.merge!(record.errors)
    false
  end

  def persisted?
    record.persisted?
  end

  def changed?
    # Rich text changes aren't tracked by `changed?` of the parent record.
    record.changed? || record.description&.changed? || coordinators_changed?
  end

  # True when the last `save` changed the record, its rich text or its
  # coordinators.
  def saved_changes?
    @saved_changes == true
  end

  def valid?
    super && validate_record
  end

  def form_path
    url_helpers = Rails.application.routes.url_helpers
    persisted? ? url_helpers.polymorphic_path(record) : url_helpers.polymorphic_path(record.class)
  end

  def form_method
    persisted? ? :patch : :post
  end

  private

  attr_reader :record

  # True when coordinators other than the current ones are staged for saving.
  def coordinators_changed?
    !@unsaved_coordinators.nil?
  end

  def validate_record
    record_valid = record.valid?
    errors.merge!(record.errors) unless record_valid
    record_valid
  end
end
