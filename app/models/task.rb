class Task < ApplicationRecord
  belongs_to :project
  has_and_belongs_to_many :coordinators,
                          class_name: "User",
                          join_table: "task_coordinators",
                          association_foreign_key: "user_id",
                          foreign_key: "task_id"

  has_many :task_applications, dependent: :destroy
  has_many :applicants, through: :task_applications, source: :user

  validates :title, presence: true
  validates :description, presence: true
  validates :coordinators, presence: true

  scope :is_published, -> {
    where(published_at: ...Time.zone.now)
  }

  def applicant?(user)
    applicants.include?(user) &&
      !task_applications.find_by(user_id: user.id).withdrawn?
  end

  def visible?
    published? && self.project.published?
  end

  def published?
    published_at.present? && published_at <= Time.zone.now
  end

  def publish
    self.published_at = Time.zone.now unless published?
  end

  def unpublish
    self.published_at = nil
  end
end
