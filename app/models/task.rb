class Task < ApplicationRecord
  belongs_to :project

  validates :title, presence: { message: "can't be blank" }, length: { minimum: 10, message: "must be at least 10 characters" }
  validates :description, presence: { message: "can't be blank" }, length: { minimum: 10, message: "must be at least 10 characters" }

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
