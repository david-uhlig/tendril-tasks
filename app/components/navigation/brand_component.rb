# frozen_string_literal: true

module Navigation
  class BrandComponent < TendrilTasks::Component
    def initialize
      @brand = Brand.new
    end
  end
end
