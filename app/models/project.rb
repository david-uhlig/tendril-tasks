class Project < ApplicationRecord
  include RichTextSanitizer

  has_many :tasks, dependent: :destroy
  has_and_belongs_to_many :coordinators,
                          class_name: "User",
                          join_table: "project_coordinators",
                          association_foreign_key: "user_id",
                          foreign_key: "project_id"

  has_rich_text :description
  has_sanitized_plain_text :description_plain_text, :description

  validates :title, presence: true
  validates :description, presence: true
  validates :coordinators, presence: true

  # Published projects with published tasks
  scope :publicly_visible, -> {
    published.includes(:tasks)
             .where(tasks: { published_at: ...Time.zone.now })
  }

  # Published projects
  scope :published, -> {
    where(published_at: ...Time.zone.now)
  }

  scope :order_by_most_recently_published_task, -> {
    joins(:tasks).order(tasks: { published_at: :desc }).distinct
  }

  # Projects without coordinators
  #
  # This happens when a user is deleted and the project is not reassigned to
  # another user.
  scope :orphaned, -> {
    left_outer_joins(:coordinators).where(project_coordinators: { user_id: nil }).distinct
  }

  def orphaned?
    coordinators.empty?
  end

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
