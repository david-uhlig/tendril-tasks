# frozen_string_literal: true

module Admin
  class Stats
    def users
      @user ||= {
        total: User.count,
        admins: User.where(role: :admin).count,
        editors: User.where(role: :editor).count,
        new: User.where("created_at >= ?", 1.week.ago).count
      }
    end

    def projects
      @projects ||= {
        total: Project.count,
        active: Project.publicly_visible.count,
        new: Project.where("created_at >= ?", 1.week.ago).count
      }
    end

    def tasks
      @tasks ||= {
        total: Task.count,
        active: Task.publicly_visible.count,
        new: Task.where("created_at >= ?", 1.week.ago).count
      }
    end

    def applications
      @applications ||= {
        total: TaskApplication.count,
        new: TaskApplication.where("created_at >= ?", 1.week.ago).count
      }
    end
  end
end
