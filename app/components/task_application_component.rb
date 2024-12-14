# frozen_string_literal: true

class TaskApplicationComponent < ApplicationComponent
  NEW_FOR = 1.week

  def initialize(application)
    @application = application
  end

  def is_new?
    @application.created_at > NEW_FOR.ago
  end
end
