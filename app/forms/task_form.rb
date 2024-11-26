# frozen_string_literal: true

class TaskForm
  include ActiveModel::Model

  attr_reader :task
  attr_accessor :submit_type

  delegate :project, :project_id=,
           :title, :title=,
           :description, :description=,
           to: :task

  def initialize(task_or_params = {})
    @task = task_or_params.is_a?(Task) ? task_or_params : Task.new
    super(task_or_params.is_a?(Task) ? {} : task_or_params)
  end

  def coordinator_ids=(ids)
    ids = Array(ids).compact_blank
    unless task.coordinator_ids.sort == ids.sort
      @unsaved_coordinators = User.find(ids)
    end
  end

  def coordinators
    @unsaved_coordinators.presence || task.coordinators
  end

  def publish=(checkbox_value)
    should_publish = ActiveModel::Type::Boolean.new.cast(checkbox_value)

    if should_publish
      task.publish unless task.published?
    else
      task.unpublish
    end
  end

  def publish
    task.published?
  end

  def project_options
    @project_options ||= Project.select(:id, :title).all.presence || []
  end

  def coordinator_options
    @coordinator_options ||= User.select(:id, :name, :avatar_url)
                                 .excluding(coordinators)
                                 .limit(Coordinators::SearchesController::NUM_SEARCH_RESULTS)
                                 .presence
    @coordinator_options ||= []
  end

  def save
    Task.transaction do
      # Update association records first so validations on them on the parent model have an effect
      task.coordinator_ids = @unsaved_coordinators.pluck(:id) if @unsaved_coordinators.present?
      task.save!
      @unsaved_coordinators = nil

      true
    end
  rescue ActiveRecord::RecordInvalid
    errors.merge!(task.errors)
    false
  end

  def persisted?
    task.persisted?
  end

  def changed?
    task.changed? || @unsaved_coordinators.present?
  end

  def valid?
    super && validate_task
  end

  def form_path
    url_helpers = Rails.application.routes.url_helpers
    persisted? ? url_helpers.task_path(task) : url_helpers.tasks_path
  end

  def form_method
    persisted? ? :patch : :post
  end

  private

  def validate_task
    task_valid = task.valid?
    errors.merge!(task.errors) unless task_valid
    task_valid
  end
end
