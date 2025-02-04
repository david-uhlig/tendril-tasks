class Project < ApplicationRecord
  has_many :tasks, dependent: :destroy
  has_and_belongs_to_many :coordinators,
                          class_name: "User",
                          join_table: "project_coordinators",
                          association_foreign_key: "user_id",
                          foreign_key: "project_id"

  validates :title, presence: true
  validates :description, presence: true
  validates :coordinators, presence: true

  scope :publicly_visible, -> {
    published.includes(:tasks)
             .where(tasks: { published_at: ...Time.zone.now })
  }

  scope :published, -> {
    where(published_at: ...Time.zone.now)
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
end
