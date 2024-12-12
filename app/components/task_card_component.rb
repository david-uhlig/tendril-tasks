# frozen_string_literal: true

class TaskCardComponent < ApplicationComponent
  SCHEME_OPTIONS = BadgeComponent::SCHEME_OPTIONS
  SCHEME_SIZE = SCHEME_OPTIONS.size

  def initialize(task, **options)
    @task = task
    @options = build_options(options)
    @badge_scheme = badge_scheme(task)
  end

  def is_new?
    @task.created_at > 2.weeks.ago
  end

  private

  def build_options(options)
    options
  end

  def badge_scheme(task)
    SCHEME_OPTIONS[task.project.id % SCHEME_SIZE]
  end
end
