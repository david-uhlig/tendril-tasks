class Project < ApplicationRecord
  validates :title, presence: true, length: { minimum: 10 }
  validates :description, presence: true, length: { minimum: 10 }

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
