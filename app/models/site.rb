# frozen_string_literal: true

# The site's name and tagline, the logo and label in the navigation, and the
# picture and text on the home page.
class Site < ApplicationRecord
  include SingletonRecord

  has_one_attached :logo

  # Shown behind the introduction on the home page. Scaled down, as clubs
  # upload photos straight from the camera.
  has_one_attached :hero_image do |attachable|
    attachable.variant :hero, resize_to_limit: [ 1200, 1200 ]
  end

  # Blank means the default, see the readers below.
  normalizes :tagline, :navigation_label, :home_title, :home_title_highlight, :home_introduction,
             with: ->(value) { value.presence }

  validates :name, presence: true, length: { maximum: 100 }
  validates :tagline, :navigation_label, :home_title, length: { maximum: 100 }
  validates :home_title_highlight, length: { maximum: 50 }
  validates :home_introduction, length: { maximum: 1000 }
  validate :home_title_highlight_in_home_title
  validates :logo,
            content_type: %i[png jpg],
            size: { less_than: 500.kilobytes },
            dimension: { min: 1..1, max: 2048..2048 }
  validates :hero_image,
            content_type: %i[png jpg webp],
            size: { less_than: 5.megabytes },
            dimension: { min: 400..300, max: 8000..8000 }

  # The label next to the logo in the navigation. Defaults to the site name.
  def navigation_label
    super || name
  end

  # The headline on the home page. Defaults to a text in the visitor's language.
  def home_title
    super || I18n.t("pages.home.title")
  end

  # The part of the headline in color. Without an own headline, defaults to the
  # part of the default headline. An own headline has none unless set.
  def home_title_highlight
    super || (I18n.t("pages.home.title_highlight") unless self[:home_title])
  end

  # The text below the headline, with paragraphs separated by blank lines.
  # Defaults to a text in the visitor's language.
  def home_introduction
    super || I18n.t("pages.home.hero")
  end

  # The paragraphs of the introduction, which blank lines separate.
  def home_introduction_paragraphs
    home_introduction.split(/\R\s*\R/).map(&:strip).compact_blank
  end

  private

  def home_title_highlight_in_home_title
    return if self[:home_title_highlight].nil? || home_title.include?(self[:home_title_highlight])

    errors.add(:home_title_highlight, :not_in_home_title)
  end
end
