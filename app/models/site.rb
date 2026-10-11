# frozen_string_literal: true

# The site's name and tagline, and the logo and label in the navigation.
class Site < ApplicationRecord
  include SingletonRecord

  has_one_attached :logo

  # Blank means the default, see the readers below.
  normalizes :tagline, :navigation_label, with: ->(value) { value.presence }

  validates :name, presence: true, length: { maximum: 100 }
  validates :tagline, :navigation_label, length: { maximum: 100 }
  validates :logo,
            content_type: %i[png jpg],
            size: { less_than: 500.kilobytes },
            dimension: { min: 1..1, max: 2048..2048 }

  # The label next to the logo in the navigation. Defaults to the site name.
  def navigation_label
    super || name
  end
end
