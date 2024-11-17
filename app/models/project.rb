class Project < ApplicationRecord
  has_many :tasks, dependent: :destroy
  has_and_belongs_to_many :coordinators,
                          class_name: "User",
                          join_table: "project_coordinators",
                          association_foreign_key: "user_id",
                          foreign_key: "project_id"

  validates :title, presence: true, length: { minimum: 10 }
  validates :description, presence: true, length: { minimum: 10 }
  validates :coordinators, presence: true

  scope :published, -> {
    where(published_at: ...Time.zone.now)
  }

  scope :has_published_task, -> {
    joins(:tasks).merge(Task.is_published).distinct
  }

  def visible?
    published? && tasks.present? && tasks.any?(&:published?)
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

  def editable_by?(user)
    coordinators.include?(user)
  end
end
