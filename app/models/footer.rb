# frozen_string_literal: true

# The footer's copyright notice and links, see `Footer::Data` for rendering it.
class Footer < ApplicationRecord
  include SingletonRecord

  # The copyright notice is optional, so a missing one is stored as "".
  normalizes :copyright, with: ->(copyright) { copyright.to_s }, apply_to_nil: true

  validates :copyright, length: { maximum: 255 }
end
