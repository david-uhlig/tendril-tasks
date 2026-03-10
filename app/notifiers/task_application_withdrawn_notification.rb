# frozen_string_literal: true

# Send a notification to coordinators when the user withdraws their application.
#
# === Usage
#   TaskApplicationWithdrawnNotification.with(record: @task_application).deliver
class TaskApplicationWithdrawnNotification < ApplicationNotifier
  include RocketChat::PrivateMessageDelivery

  validates :record, presence: true
  recipients -> { record.coordinators }

  notification_methods do
    def markdown_message
      markdown = MarkdownHelper
      applicant, task, project = record.user.username, record.task, record.task.project
      count = task.task_applications.count

      header = t(
        ".markdown.message",
        applicant:,
        task_link: markdown.link_to(task.title, url_for(task))
      )
      summary = t(
        "notifiers.task_application.summary.markdown",
        project_link: markdown.link_to(project.title, url_for(project)),
        count: count
      )

      "#{header}\n#{summary}".strip
    end
  end
end
