# frozen_string_literal: true

class Page < ApplicationRecord
  has_rich_text :content
end
