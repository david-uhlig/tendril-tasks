class TaskApplication < ApplicationRecord
  # Amount of time that must elapse after the application is submitted before
  # a notification is sent. Provides applicants an opportunity to review, edit,
  # or withdraw the application before the notification is dispatched to
  # coordinators.
  NOTIFICATION_DELAY = 30.minutes
  # Amount of time in that the application is editable by the applicant.
  # Within this timeframe the application will be deleted, afterward it
  # will be set to `status: :withdrawn`
  # If set to `0.minutes` the application is not editable.
  GRACE_PERIOD = NOTIFICATION_DELAY

  belongs_to :task
  belongs_to :user

  # Describe the status of the application
  # Purely informal for coordinators. They do not cause any user facing actions.
  enum :status, {
    received: 0,
    under_review: 10,
    interviewing: 20,
    on_hold: 30,
    accepted: 90,
    rejected: 91,
    withdrawn: 92
  }

  validates :task, presence: true, uniqueness: { scope: :user }
  validates :user, presence: true

  def withdraw
    self.withdrawn_at = Time.zone.now
    self.status = :withdrawn
  end

  def editable?
    # Making sure the result is consistent during a request
    @_editable ||= self.created_at > GRACE_PERIOD.ago
  end
end
