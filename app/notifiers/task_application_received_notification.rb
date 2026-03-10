# frozen_string_literal: true

# Send notifications to task coordinators when a user submits an application.
#
# Send the notification right away or delay it by a few minutes to give the
# user a chance to withdraw or edit their application.
#
# @example
#   TaskApplicationReceivedNotification.with(record: @task_application).deliver
# @example
#   # Delay sending the notification by 30 minutes.
#   TaskApplicationReceivedNotification.with(record: @task_application, delay: 30.minutes).deliver
class TaskApplicationReceivedNotification < ApplicationNotifier
  include RocketChat::PrivateMessageDelivery

  validates :record, presence: true
  recipients -> { record.coordinators }

  notification_methods do
    # Builds the Markdown formatted message for the notification.
    def markdown_message
      markdown = MarkdownHelper
      applicant, task, project, comment = record.user.username, record.task, record.task.project, record.comment
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
      comment = markdown.italic(comment)

      "#{header}\n#{summary}\n\n#{comment}".strip
    end
  end
end
