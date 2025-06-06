# frozen_string_literal: true

# Application for a task by a user.
#
# The application is created when the user submits the task application form.
# The application can be edited by the user until the grace period has passed.
# After that, the application is set to `status: :withdrawn` and is no longer
# editable. The application can be at any time.
class TaskApplication < ApplicationRecord
  # Amount of time in that the application is editable by the applicant.
  # Within this timeframe the application will be deleted if the user withdraws,
  # afterward it will be set to `status: :withdrawn`. If set to `0.minutes` the
  # application is not editable.
  # TODO: This could become a configuration option in the UI.
  GRACE_PERIOD = 30.minutes
  # Amount of time that must elapse after the application is submitted before
  # a notification is sent. Provides applicants an opportunity to review, edit,
  # or withdraw the application before the notification is dispatched to
  # coordinators. Should be equal to or greater than the grace period in most
  # cases.
  NOTIFICATION_DELAY = GRACE_PERIOD

  belongs_to :task
  belongs_to :user

  # Informal status of the application, set through coordinators.
  # Does not cause any user facing actions.
  enum :status, {
    received: 0,
    under_review: 10,
    interviewing: 20,
    on_hold: 30,
    accepted: 90,
    rejected: 91,
    withdrawn: 92
  }

  # Notifications associated with the applications.
  # - Coordinators receive a notification when a user submits a new application
  #   after the `NOTIFICATION_DELAY` passes.
  # - No notification is sent when the user updates or withdraws the application
  #   within the grace period.
  # - Coordinators receive a notification when the user withdraws the
  #   application after the grace period passes.
  has_many :noticed_events, as: :record, dependent: :destroy, class_name: "Noticed::Event"
  has_many :notifications, through: :noticed_events, class_name: "Noticed::Notification"

  validates :task, presence: true, uniqueness: { scope: :user }
  validates :user, presence: true

  after_create_commit :notify_coordinators_about_new_application
  after_update_commit :notify_coordinators_about_withdrawn_application, if: -> { withdrawn? }

  def withdraw
    self.withdrawn_at = Time.zone.now
    self.status = :withdrawn
  end

  def editable?
    # Making sure the result is consistent during a request
    @_editable ||= self.created_at > GRACE_PERIOD.ago
  end

  def coordinators
    @coordinators ||= task.coordinators
  end

  private

  def notify_coordinators_about_new_application
    NewTaskApplicationNotifier
      .with(record: self, delay: NOTIFICATION_DELAY)
      .deliver
  end

  def notify_coordinators_about_withdrawn_application
    WithdrawnTaskApplicationNotifier
      .with(record: self)
      .deliver
  end
end
