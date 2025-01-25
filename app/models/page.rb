# frozen_string_literal: true

class Page < ApplicationRecord
  has_rich_text :content

  validates :content, presence: true

  after_save :expire_cache
  after_destroy :expire_cache

  private

  def expire_cache
    Rails.cache.delete("footer_data")
  end
end
