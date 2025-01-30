# frozen_string_literal: true

class Page < ApplicationRecord
  has_rich_text :content

  validates :content, presence: true
end
