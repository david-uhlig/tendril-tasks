class TaskApplication < ApplicationRecord
  belongs_to :task
  belongs_to :user

  validates :task, presence: true, uniqueness: { scope: :user }
  validates :user, presence: true
end
