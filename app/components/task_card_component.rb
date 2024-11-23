# frozen_string_literal: true

class TaskCardComponent < ApplicationComponent
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
    schemes = BadgeComponent::SCHEME_OPTIONS
    size = schemes.size
    BadgeComponent::SCHEME_OPTIONS[task.project.id % size]
  end
end
