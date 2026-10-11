# frozen_string_literal: true

class Page < ApplicationRecord
  # The legal pages admins can create, by slug. They're linked in the footer.
  LEGAL_SLUGS = %w[ imprint privacy-policy terms-of-service ].freeze

  has_rich_text :content

  validates :content, presence: true

  scope :legal, -> { where(slug: LEGAL_SLUGS) }
end
