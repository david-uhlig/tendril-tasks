# frozen_string_literal: true

# Send notification to task coordinators when user submits an application.
#
# Send the notification right away or delay it by a few minutes to give the
# user a chance to withdraw or edit the application.
#
# === Usage
#   NewTaskApplicationNotifier.with(record: @task_application).deliver
#
#   NewTaskApplicationNotifier.with(record: @task_application, delay: 30.minutes).deliver
class NewTaskApplicationNotifier < ApplicationNotifier
  include RocketChatNotifier

  recipients -> { record.coordinators }

  validates :record, presence: true

  notification_methods do
    def rocket_chat_message
      output = t(".markdown_message", **data)
      output << t(".markdown_comment", comment: record.comment) if has_comment?
      output
    end

    def data
      {
        applicant: record.user.username,
        task_title: record.task.title,
        task_url: task_url(record.task),
        initiative_title: record.task.project.title,
        initiative_url: project_url(record.task.project),
        comment: record.comment
      }
    end

    def has_comment?
      record.comment.present?
    end
  end
end
