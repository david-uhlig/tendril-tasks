class Project < ApplicationRecord
  has_many :tasks, dependent: :destroy

  validates :title, presence: true, length: { minimum: 10 }
  validates :description, presence: true, length: { minimum: 10 }

  def active?
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
