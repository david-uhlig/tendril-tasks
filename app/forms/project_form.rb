# frozen_string_literal: true

class ProjectForm
  include ActiveModel::Model

  attr_reader :project

  delegate :title, :title=,
           :description, :description=,
           to: :project

  def initialize(project_or_params = {})
    @project = project_or_params.is_a?(Project) ? project_or_params : Project.new
    super(project_or_params.is_a?(Project) ? {} : project_or_params)
  end

  # Stages the coordinators until the form is saved. Ignores ids of users that
  # no longer exist, e.g. when a user was deleted while the form was open. An
  # empty list removes all coordinators, which fails validation on save.
  def coordinator_ids=(ids)
    users = User.where(id: Array(ids).compact_blank).to_a
    @unsaved_coordinators =
      if users.map(&:id).sort == project.coordinator_ids.sort
        nil
      else
        users
      end
  end

  def coordinators
    @unsaved_coordinators || project.coordinators
  end

  def publish=(checkbox_value)
    should_publish = ActiveModel::Type::Boolean.new.cast(checkbox_value)

    if should_publish
      project.publish
    else
      project.unpublish
    end
  end

  def publish
    project.published?
  end

  def coordinator_options
    @coordinator_options ||= User.select(:id, :name, :avatar_url)
                                 .excluding(coordinators)
                                 .limit(Coordinators::SearchesController::NUM_SEARCH_RESULTS)
                                 .to_a
  end

  def save
    has_changes = changed?
    @saved_changes = false

    Project.transaction do
      # Update association records first so validations on them on the parent model have an effect
      project.coordinators = @unsaved_coordinators if coordinators_changed?
      project.save!
      @unsaved_coordinators = nil
      @saved_changes = has_changes

      true
    end
  rescue ActiveRecord::RecordInvalid
    errors.merge!(project.errors)
    false
  end

  def persisted?
    project.persisted?
  end

  def changed?
    # Rich text changes aren't tracked by `changed?` of the parent record.
    project.changed? || project.description&.changed? || coordinators_changed?
  end

  # True when the last `save` changed the record, its rich text or its
  # coordinators.
  def saved_changes?
    @saved_changes == true
  end

  def valid?
    super && validate_project
  end

  def form_path
    url_helpers = Rails.application.routes.url_helpers
    persisted? ? url_helpers.project_path(project) : url_helpers.projects_path
  end

  def form_method
    persisted? ? :patch : :post
  end

  class << self
    def human_attribute_name(attribute, **options)
      Project.human_attribute_name(attribute, **options)
    end
  end

  private

  # True when coordinators other than the current ones are staged for saving.
  def coordinators_changed?
    !@unsaved_coordinators.nil?
  end

  def validate_project
    project_valid = project.valid?
    errors.merge!(project.errors) unless project_valid
    project_valid
  end
end
