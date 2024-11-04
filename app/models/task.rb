class Task < ApplicationRecord
  belongs_to :project
  has_and_belongs_to_many :coordinators,
                          class_name: "User",
                          join_table: "task_coordinators",
                          association_foreign_key: "user_id",
                          foreign_key: "task_id"

  has_many :task_applications, dependent: :destroy
  has_many :applicatiants, through: :task_applications, source: :user

  validates :title, presence: { message: "can't be blank" }, length: { minimum: 10, message: "must be at least 10 characters" }
  validates :description, presence: { message: "can't be blank" }, length: { minimum: 10, message: "must be at least 10 characters" }
  validates :coordinators, presence: true

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
