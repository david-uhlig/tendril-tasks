# frozen_string_literal: true

class TaskForm
  include CoordinatedRecordForm
  coordinated_record Task

  delegate :project, :project_id, :project_id=, to: :task

  def project_options
    @project_options ||= Project.select(:id, :title)
                                .order(:title)
                                .to_a
  end
end
