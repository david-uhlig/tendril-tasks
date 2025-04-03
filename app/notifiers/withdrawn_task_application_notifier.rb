# frozen_string_literal: true

# Send notification to task coordinators when user withdraws an application.
#
# === Usage
#   WithdrawnTaskApplicationNotifier.with(record: @task_application).deliver

class WithdrawnTaskApplicationNotifier < ApplicationNotifier
  include RocketChatNotifier

  recipients -> { record.coordinators }

  validates :record, presence: true

  notification_methods do
    def rocket_chat_message
      t(".markdown_message", **data)
    end

    def data
      {
        applicant: record.user.username,
        task_title: record.task.title,
        task_url: task_url(record.task),
        initiative_title: record.task.project.title,
        initiative_url: project_url(record.task.project)
      }
    end
  end
end
