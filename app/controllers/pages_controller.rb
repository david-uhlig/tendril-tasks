# frozen_string_literal: true

class PagesController < ApplicationController
  RECENT_TASKS_LIMIT = 3

  def home
    @site = Site.instance

    # Count what the tasks and initiatives pages list, so the numbers match
    # what visitors find after clicking through.
    @open_tasks_count = Task.publicly_visible.count
    @initiatives_count = Project.publicly_visible.count
    @new_tasks_count = Task.publicly_visible
                           .where(created_at: Task::NEW_TASK_THRESHOLD.ago..)
                           .count

    # Task cards need a signed in user, like the tasks page
    if user_signed_in?
      # Like the dashboard, which lists these applications
      @applied = current_user.task_applications.where.not(status: :withdrawn).exists?
      @recent_tasks = Task.publicly_visible
                          .includes(:coordinators, :project, :applicants)
                          .order(published_at: :desc)
                          .limit(RECENT_TASKS_LIMIT)
    end
  end
end
