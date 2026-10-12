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

  # Projects with published tasks, ordered by their most recently published task
  #
  # Orders by a correlated subquery instead of joining the tasks, which would
  # require `DISTINCT` combined with ordering by a column outside the select
  # list. Only SQLite accepts that.
  scope :order_by_most_recently_published_task, -> {
    tasks = Task.arel_table
    latest_published_at = Task.is_published
                              .where(tasks[:project_id].eq(arel_table[:id]))
                              .select(tasks[:published_at].maximum)

    where(id: Task.is_published.select(:project_id))
      .order(Arel::Nodes::Grouping.new(latest_published_at.arel).desc)
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
    self.published_at = Time.zone.now unless published?
  end

  def unpublish
    self.published_at = nil
  end
end
