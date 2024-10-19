class Task < ApplicationRecord
  belongs_to :project
  has_and_belongs_to_many :coordinators,
                          class_name: "User",
                          join_table: "task_coordinators",
                          association_foreign_key: "user_id",
                          foreign_key: "task_id"

  validates :title, presence: { message: "can't be blank" }, length: { minimum: 10, message: "must be at least 10 characters" }
  validates :description, presence: { message: "can't be blank" }, length: { minimum: 10, message: "must be at least 10 characters" }
  validates :coordinators, presence: true

  def active?
    published? && self.project.published?
  end

  def published?
    published_at.present? && published_at <= Time.zone.now
  end

  def publish
    self.published_at = Time.zone.now
  end

  def unpublish
    self.published_at = nil
  end
end
