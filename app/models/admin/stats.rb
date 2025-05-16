module Admin
  class Stats
    RECENT_TIMEFRAME = 1.week.ago

    def users
      @users ||= {
        total: User.count,
        admins: User.where(role: :admin).count,
        editors: User.where(role: :editor).count,
        new: recent_count(User)
      }
    end

    def projects
      @projects ||= {
        total: Project.count,
        active: Project.publicly_visible.count,
        new: recent_count(Project)
      }
    end

    def tasks
      @tasks ||= {
        total: Task.count,
        active: Task.publicly_visible.count,
        new: recent_count(Task)
      }
    end

    def applications
      @applications ||= {
        total: TaskApplication.count,
        new: recent_count(TaskApplication)
      }
    end

    def active_job
      return {} unless ActiveJob.respond_to?(:jobs)

      @active_job ||= {
        failed: count_if_responds_to(ActiveJob.jobs, :failed),
        scheduled: count_if_responds_to(ActiveJob.jobs, :scheduled),
        in_progress: count_if_responds_to(ActiveJob.jobs, :in_progress),
        finished: count_if_responds_to(ActiveJob.jobs, :finished)
      }
    end

    def active_storage
      @active_storage ||= {
        files: ActiveStorage::Attachment.count,
        blobs: ActiveStorage::Blob.count,
        size: ActiveStorage::Blob.sum(:byte_size)
      }
    end

    private

    def recent_count(model)
      model.where("created_at >= ?", RECENT_TIMEFRAME).count
    end

    def count_if_responds_to(object, method_name)
      object.respond_to?(method_name) ? object.public_send(method_name).count : 0
    rescue StandardError => e
      0
    end
  end
end
