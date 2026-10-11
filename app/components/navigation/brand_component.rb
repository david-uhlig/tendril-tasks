# frozen_string_literal: true

module Navigation
  class BrandComponent < TendrilTasks::Component
    def initialize
      @site = Site.instance
    end
  end
end
