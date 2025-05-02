class Task < ApplicationRecord
  include RichTextSanitizer

  NEW_TASK_THRESHOLD = 2.weeks

  belongs_to :project
  has_and_belongs_to_many :coordinators,
                          class_name: "User",
                          join_table: "task_coordinators",
                          association_foreign_key: "user_id",
                          foreign_key: "task_id"

  has_many :task_applications, dependent: :destroy
  has_many :applicants, through: :task_applications, source: :user

  has_rich_text :description
  has_sanitized_plain_text :description_plain_text, :description

  validates :title, presence: true
  validates :description, presence: true
  validates :coordinators, presence: true

  scope :publicly_visible, -> {
    is_published.includes(:project)
                .where(project: { published_at: ...Time.zone.now })
  }

  scope :is_published, -> {
    where(published_at: ...Time.zone.now)
  }

  # Tasks without coordinators
  #
  # This happens when a user is deleted and the task is not reassigned to
  # another user.
  scope :orphaned, -> {
    left_outer_joins(:coordinators).where(task_coordinators: { user_id: nil }).distinct
  }

  # Returns true if the task is considered as new
  def new?
    created_at > NEW_TASK_THRESHOLD.ago
  end

  # Returns true if the task has no coordinators
  def orphaned?
    coordinators.empty?
  end

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
