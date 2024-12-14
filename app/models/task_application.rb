class TaskApplication < ApplicationRecord
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
end
