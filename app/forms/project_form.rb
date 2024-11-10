# frozen_string_literal: true

class ProjectForm
  include ActiveModel::Model

  attr_reader :project
  attr_accessor :submit_type

  delegate :title, :title=,
           :description, :description=,
           to: :project

  def initialize(project_or_params = {})
    @project = project_or_params.is_a?(Project) ? project_or_params : Project.new
    super(project_or_params.is_a?(Project) ? {} : project_or_params)
  end

  def coordinator_ids=(ids)
    ids = Array(ids).compact_blank
    unless project.coordinator_ids.sort == ids.sort
      @unsaved_coordinators = User.find(ids)
    end
  end

  def coordinators
    @unsaved_coordinators.presence || project.coordinators
  end

  def publish=(checkbox_value)
    should_publish = ActiveModel::Type::Boolean.new.cast(checkbox_value)

    if should_publish
      project.publish unless project.published?
    else
      project.unpublish
    end
  end

  def publish
    project.published?
  end

  def coordinator_options
    @coordinator_options ||= User.select(:id, :name, :avatar_url).exclude(coordinators).limit(15).presence || []
  end

  def save
    Project.transaction do
      # Update association records first so validations on them on the parent model have an effect
      project.coordinator_ids = @unsaved_coordinators.pluck(:id) if @unsaved_coordinators.present?
      project.save!
      @unsaved_coordinators = nil

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
    project.changed? || @unsaved_coordinators.present?
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

  private

  def validate_project
    project_valid = project.valid?
    errors.merge!(project.errors) unless project_valid
    project_valid
  end
end
